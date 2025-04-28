public class LobbyViewModel {
	private var _lobbiesSubject:BehaviorSubject<Array<Lobby>>;
	
	public var lobbies(get,never): Observable<List<Lobby>>;
	
	public var createLobbyCommand:ICommand;
    private var _lobbyService:ILobbyService;
	public new(lobbyService:ILobbyService)
	{
        _lobbyService = lobbyService;
		_lobbiesSubject = new BehaviorSubject<Array<Lobby>>(new Array<Lobby>());
		createLobbyCommand = new RelayCommand<String>(createLobby);
		loadLobbies();
	}
	private function loadLobbies():Void
	{
        _lobbyService.getActiveLobbies().subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error loading lobbies: "+e);},
                (lobbies)-> {_lobbiesSubject.on_next(lobbies) }
            )
        );
	}
	private function createLobby(name:String):Void
	{
        _lobbyService.createLobby(name).subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error creating lobby: "+e);},
                (lobby)-> 
                {
                    trace("Lobby created: "+lobby.name);
                    loadLobbies(); 
                }
            )
        );
	}
}