package ui.models;

import haxe.ui.assets.ImageInfo;
import haxe.ui.util.Variant;

class FriendModel {
    @:isVar public var nickName(default,default):String;
    @:isVar public var profileImageUrl(default,default):String;
    @:isVar public var id(default,default):String;
    @:isVar public var image:Variant;
    public function new(nickName:String="",profileImageUrl:String="",id:String="") {
        this.nickName = nickName;
        this.profileImageUrl = profileImageUrl;
        this.id = id;
    }
}