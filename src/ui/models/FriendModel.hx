package ui.models;

import haxe.ui.assets.ImageInfo;
import haxe.ui.util.Variant;

class FriendModel {
    @:isVar public var nickName(default,default):String;
    @:isVar public var profileImageUrl(default,default):String;
    @:isVar public var profileImageLocalUrl(default,default):String;
    @:isVar public var id(default,default):String;
    @:jignored @:isVar public var image:Variant;
    public function new(nickName:String="",profileImageUrl:String="",id:String="",profileImageLocalUrl="") {
        this.nickName = nickName;
        this.profileImageUrl = profileImageUrl;
        this.id = id;
        this.profileImageLocalUrl = profileImageLocalUrl;
    }
}