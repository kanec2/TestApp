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