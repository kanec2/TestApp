package ui.models;

class FriendModel {
    @:isVar public var nickName(default,default):String;
    @:isVar public var profileImageUrl(default,default):String;
    @:isVar public var id(default,default):String;

    public function new(nickName:String="",profileImageUrl:String="",id:String="") {
        this.nickName = nickName;
        this.profileImageUrl = profileImageUrl;
        this.id = id;
    }
}