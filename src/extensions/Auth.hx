package extensions;

import http.HttpResponse;
import thenshim.Promise;
import http.HttpError;
using haxe.Exception;
using haxe.ds.Either;
using io.colyseus.events.EventHandler;
//using io.colyseus.error.MatchMakeError;
import tink.Url;
import http.HttpClient;
import queues.QueueFactory;
@:keep
@:generic
typedef AuthData<T> = {
    ?token: String,
    ?user: T,
}

//typedef HttpCallback = (MatchMakeError,AuthData<Dynamic>)->Void;

class EndpointSettings {
	public var hostname:String;
	public var port:Int;
	public var useSSL:Bool;

    public function new (hostname: String, port: Int, useSSL: Bool) {
        this.hostname = hostname;
        this.port = port;
        this.useSSL = useSSL;
    }
}

@:keep
class Auth {
    public static var PATH = "/api";
    public var settings: EndpointSettings;
    private var authToken:String;
    private var http: haxe.Http;
    private var client:HttpClient = new HttpClient();
    private var _token: String;
    private var _initialized: Bool;
    var headers = [
        "Access-Control-Allow-Origin" => "*", 
        "Content-Type"=> "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer WoW-vErY-sEcReT-MuCh-sEcUrE"
    ];
    private var onChangeHandlers = new EventHandler<Dynamic->Void>();

    public function new (endpointOrHostname: String, ?port: Int, ?useSSL: Bool) {
        Storage.getItem("colyseus-auth-token").handle(function(token) {
            this.token = token;
        });
        if (port == null && useSSL == null) {
            var url: Url = Url.parse(Std.string(endpointOrHostname));
            var useSSL = false;// (url.scheme == "https" || url.scheme == "wss");
            var port = (url.host.port != null)
                ? url.host.port
                : (useSSL)
                    ? 443
                    : 80;

            this.settings = new EndpointSettings(url.host.name, port, useSSL);

        } else {
            this.settings =  new EndpointSettings(endpointOrHostname, port, useSSL);
        }
        client.followRedirects = false;
        client.requestQueue = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE);
        client.defaultRequestHeaders = headers;
    }

    public var token (get, set): String;
    function get_token () : String { return this.authToken; }
    function set_token (value: String) : String {
        if (value == null) {
            Storage.removeItem("colyseus-auth-token");
        } else {
            Storage.setItem("colyseus-auth-token", value);
        }
        this.authToken = value;
        return value;
    }

    public function onChange(callback: (AuthData<Dynamic>)->Void) {
        this.onChangeHandlers += callback;

        if (!this._initialized) {
            this._initialized = true;
            this.getUserData(function(err, userData) {
                if (err != null) {
                    // user is not logged in, or service is down
                    this.emitChange({ user: null, token: null });

                } else {
                    this.emitChange(userData);
                }
            });
        }

		return function() {
			this.onChangeHandlers -= callback;
		};
    }

    /*public function getUserData(callback: (MatchMakeError,AuthData<Dynamic>)->Void) {
        if (this.token != null) {
            this.request("GET",PATH + "/userdata", null, callback);
            //this.http.get(PATH + "/userdata", null, callback);
        } else {
            callback(new MatchMakeError(-1, "missing auth.token"), null);
        }
    }*/

    public function registerWithEmailAndPassword(email: String, password: String, opts_or_callback: Dynamic, ?callback: (MatchMakeError,AuthData<Dynamic>)->Void) {
        var options: Dynamic = null;

        if (callback == null) {
            callback = opts_or_callback;
        } else {
            options = opts_or_callback;
        }        
        trace("ready to request");
        this.request("POST", PATH + "/register", {email: email, password: password, options: options},function(err, data) {
            if (err != null) {
                callback(err, null);
            } else {
                this.emitChange(data);
                callback(null, data);
            }
        });

    }

    public function signInWithEmailAndPassword(email: String, password: String, callback: (MatchMakeError,AuthData<Dynamic>)->Void) {
        this.request("POST", PATH + "/login", {email: email, password: password},function(err, data) {
            if (err != null) {
                callback(err, null);
            } else {
                this.emitChange(data);
                callback(null, data);
            }
        });
        /*
        client.post(buildHttpEndpoint(PATH + "/login"),{email: email, password: password}).then(response -> {
            var bd = response.bodyAsJson;
            this.emitChange(bd);
            //{token: "WoW-vErY-sEcReT-MuCh-sEcUrE", response.body};
            callback(null,{token: "WoW-vErY-sEcReT-MuCh-sEcUrE", user: bd});
        }, (error:HttpError) -> {
            var errmsg = error.bodyAsJson.error;
            var err = new MatchMakeError(error.httpStatus, errmsg);
            callback(err,null);
        });*/
    }

    public function signInAnonymously(opts_or_callback: Dynamic, ?callback: (MatchMakeError,AuthData<Dynamic>)->Void) {
        var options: Dynamic = null;

        if (callback == null) {
            callback = opts_or_callback;
        } else {
            options = opts_or_callback;
        }
        var rbody = haxe.Json.stringify({body: cast {options: options}});

        this.request("POST", PATH + "/anonymous", rbody, function(err, data) {
            if (err != null) {
                callback(err, null);
            } else {
                this.emitChange(data);
                callback(null, data);
            }
        });
    }

    public function sendPasswordResetEmail(email: String, callback: (MatchMakeError,AuthData<Dynamic>)->Void) {

        var rbody = haxe.Json.stringify({body: cast {email: email}});
        
        this.request("POST",PATH + "/forgot-password", rbody, function(err, data) {
            if (err != null) {
                callback(err, null);
            } else {
                callback(null, data);
            }
        });
    }

    public function signInWithProvider(providerName: String, ?options: Dynamic) {
        throw new Exception("not implemented");
    }

    public function signOut() {
        this.emitChange({ user: null, token: null });
    }

    public function emitChange(authData: AuthData<Dynamic>) {
		this.token = authData.token;
        this.onChangeHandlers.dispatch(authData);
    }

    
    private function request(method: String, segments: String, body: Dynamic, callback: (MatchMakeError,Dynamic)->Void) {

        var reqEndpoint = buildHttpEndpoint(segments);
        var headers:Map<String,String> = new Map<String,String>();

        if (body != null) {
            headers.set("Access-Control-Allow-Origin", "*");
            headers.set("Content-Type", "application/json");
        }
        headers.set("Authorization","Bearer "+"WoW-vErY-sEcReT-MuCh-sEcUrE");
        headers.set("Accept", "application/json");
        var promise = switch (method) {
            case "POST" : client.post(reqEndpoint, body,null,headers);
            case "PUT" : client.put(reqEndpoint, body,null,headers);
            case "GET" : client.get(reqEndpoint,null,headers);
            case _: throw "What was that?";
        }
        promise.then(response -> {
            var bd = haxe.Json.parse(response.bodyAsJson);
            this.emitChange(bd);
            callback(null,response);//{token: "WoW-vErY-sEcReT-MuCh-sEcUrE", user: bd});
        }, (error:HttpError) -> {
            var code = error.httpStatus;
            var message = error.bodyAsJson.error;
            callback(new MatchMakeError(code, message),null);
        });
       
    }
    private function buildHttpEndpoint(segments: String) {
        return '${(this.settings.useSSL) ? "https" : "http"}://${this.settings.hostname}${this.getEndpointPort()}/${segments}';
    }

    private function getEndpointPort() {
        return (this.settings.port != 80 && this.settings.port != 443)
            ? ':${this.settings.port}'
            : '';
    }
}