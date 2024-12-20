package api.models;

class JsonModels {
    
}

typedef FriendsData = {
    public var nickName:String;
    public var profileImageUrl:String;
    public var profileImageLocalUrl:String;
    public var id:String;
}
typedef RootFriendsData = {
    public var friends:Array<FriendsData>;
}

typedef LobbyData = {
    public var lobbyId:String;
    public var players:Array<LobbyUser>;
    public var hostId:String;
    public var rules:String;
    public var lobbyCapacity:Int;
    public var gameMode:String;
}

typedef LobbyUser = {
    public var nickName:String; 
    public var playerId:String;
    public var selectedRace:String; 
    public var lobbySpot:Int; 
    public var rating:Int; 
    public var rank:String;
    public var team:Null<String>;
}