package services;
import extensions.Auth;
import haxe.ui.events.AppEvent;
import extensions.Auth;
import libs.rx.Scheduler;
import libs.rx.observables.MakeScheduled.SubscribeOnThis;
import libs.rx.Observer;
import libs.rx.observables.ObserveOnThis;
import api.models.JsonModels.FriendsData;
import http.HttpClient;
import http.HttpError;
import hx.injection.config.Configuration;
import hx.files.File.FileWriteMode;
import hx.files.Dir;
import hx.files.Path;
import haxe.Json;
import libs.rx.Subscription;
import hx.injection.Service;
import io.colyseus.Client;
using libs.rx.Observable;
abstract class IAuthenticationService implements Service
{ 
    abstract public function signIn(email:String, pass:String):Observable<String>;
    abstract public function register(email:String, pass:String):Observable<Bool>;
}
class AuthenticationService extends IAuthenticationService{
    var auth:Auth;// = new Auth("localhost", 2567);
    var _config : Config;
    //var client: Client;
    //var _httpClient : HttpClientService;
    public function new(configuration : Config,httpClient : HttpClientService) {
        this._config = configuration;
        //this.client = new Client("localhost", 2567);
        //var httpClient.getClient();
        this.auth = new Auth(httpClient, "localhost", 2567);
    }

    public function register(email,pass):Observable<Bool>
    {
        trace("try to register");
        var token:String = "";
        var userData:Dynamic = null;
        return Observable.create(_observer -> {
            //this.client.
            this.auth.registerWithEmailAndPassword(email,pass, (regErr, regData) ->{
                if(regErr!=null){
                    trace("register failed: "+regErr.message);
                    _observer.on_error(regErr.message);
                }
                if(regData != null){
                    trace("register success: "+regData.token);
                    token = regData.token;
                    userData = regData.user;
                    _observer.on_completed();
                }
            });
            return Subscription.empty();
        });
    }

    public function signIn(email,pass):Observable<String>
    {
        trace("try to login");
        // auth
        this.auth.onChange(function (user) {
            trace('auth.onChange', user);
        });
        return Observable.create(_observer -> {
            this.auth.signInWithEmailAndPassword(email,pass, (err, data) ->{
                trace("Auth?");
                if(err != null){
                    trace("login failed: "+err.message);
                    _observer.on_error(err.message);
                }
                if(data != null){
                    trace(data);
                    _observer.on_next(data.token);
                    _observer.on_completed();
                }
            });
            return Subscription.empty();
        });
    }
}