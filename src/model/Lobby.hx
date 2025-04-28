typedef RootLobbyData = {
    public var lobbies:Array<Lobby>;
}
typedef Lobby = { 
    public var name:String; 
    public var owner:String; 
    public var members:Array<String>; 
}