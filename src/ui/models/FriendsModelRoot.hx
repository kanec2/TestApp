package ui.models;

import hx.concurrent.collection.SynchronizedArray;

class FriendsModelRoot {
    public var friends:Array<FriendModel>;

    public function new() {
        
    }
    public function fromArray(friends:Array<FriendModel>) {
        this.friends = friends;
    }
    public function fromSyncArray(friends:SynchronizedArray<FriendModel>){
        this.friends = new Array<FriendModel>();
        for(friend in friends)
            this.friends.push(friend);
    }
}