abstract class ILobbyService 
{ 
    abstract public function getActiveLobbies():Observable<Array<Lobby>>; 
    abstract public function createLobby(name:String):Observable<Lobby>; 
}

class LobbyService extends ILobbyService {
	private var _httpClient:IHttpClientService;

	public function new(httpClient:IHttpClientService )
	{
		_httpClient = httpClient;
	}

    public function getActiveLobbies() : Observable<Array<Lobby>> 
    { 
        return Observable.create(_observer -> {
            _httpClient.getClient().get(_config.lobbiesGetUrl, [], []).then(response -> {
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });
            return Subscription.empty();
        }).map((rawJson) ->{
            var json:RootLobbyData = Json.parse(rawJson);
            return json.lobbies;
        });
    }

    function isSuccessStatusCode(statusCode:Int):Bool return statusCode >= 200 && statusCode <300;
    
    public function addFriend(username:String) : Observable<Bool>
    { 
        return Observable.create(_observer->{
            _httpClient.getClient().post(_config.addFriendsUrl, {username: username}, [], []).then(response -> {
                _observer.on_next(isSuccessStatusCode(response.httpStatus));
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });

            return Subscription.empty();
        });
    }

    public function createLobby(name:String ) : Observable<Lobby>
    { 
        return Observable.create(_observer -> {
            _httpClient.getClient().post(_config.lobbiesCreateUrl, {name:name}, [], []).then(response -> {
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });
            return Subscription.empty();
        }).map((rawJson) ->{
            var json:RootLobbyData = Json.parse(rawJson);
            return json.lobbies[0];
        });
    }
}