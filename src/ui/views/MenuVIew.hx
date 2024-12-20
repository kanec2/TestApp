package ui.views;

import ui.models.FriendModel;
import hx.concurrent.collection.SynchronizedArray;
import ui.components.LobbyWindow;
import haxe.ui.notifications.NotificationData.NotificationActionData;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.NotificationEvent;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;
@:build(haxe.ui.ComponentBuilder.build("assets/ui/views/menu-view.xml"))
class MenuView extends Box {

    public function new() {
        super();
        joinLobby("fddsfsd3223");
        /*
        friendList.dataSource.onChange = function(){
            if(friendList.dataSource.size == 0){
                friendList.hide();
                noFriendBox.show();
            }
            else {
                friendList.show();
                noFriendBox.hide();
            }
        }*/
    }
   
    var getFriendsCommand:(userId:String) -> Void;
    var friendsDataSource:Array<FriendModel> = new Array<FriendModel>();
    @:bind(NotificationManager.instance, NotificationEvent.ACTION)
    private function onNotificationManagerAction(event:NotificationEvent) {
        var actionData = event.data;//.actionData;
        //trace(event.value);
        //trace("You chose " + actionData.text + "!");
        //actionNotificationEventLabel.text = "You chose " + actionData.text + "!";
    }

    public function init(getFriendList:(userId:String) -> Void) {
        getFriendsCommand = getFriendList;
    }

    public function setFriends(friends:Array<FriendModel>){
        //trace("we have new friends");
        friendList.dataSource.data = friends;
    }

    

    @:bind(actionNotificationCallbackButton, MouseEvent.CLICK)
    private function onActionNotificationCallback(_) {
        //actionNotificationCallbackLabel.text = "";
        //trace("ggg");
        NotificationManager.instance.addNotification({
            title: "'Nagib19' invites you to join his lobby.",
            body: "Click on the buttons below to accept or decline invitation",
            actions: [{
                text: "Accept",
                callback: onNotificationActionCallback
            }, {
                text: "Decline",
                callback: onNotificationActionCallback
            }]
        });
    }
    
    private function onNotificationActionCallback(actionData:NotificationActionData) {
        var decision = actionData.text;
        var lobbyId = "YUFhkw3423";
        if(decision == "Accept")
            joinLobby(lobbyId);
        else getFriendsCommand("dsads");
        //trace("You chose " + actionData.text + "!");
        //actionNotificationCallbackLabel.text = "You chose " + actionData.text + "!";
        return true; // return value indicates if the notification should close or not
    }

    private function joinLobby(lobbyId){
        var lobbyInfo = Mock.getLobbyInfo(lobbyId);
        trace(lobbyInfo);
        var lobbyWindow:LobbyWindow = new LobbyWindow();
        lobbyWindow.setLobbyInfo(lobbyInfo);
        this.addComponent(lobbyWindow);
    }
   
}