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

    public function setFriends(friends:SynchronizedArray<FriendModel>){
        trace("we have new friends");
        var arr:Array<FriendModel> = new Array<FriendModel>();
        for (friend in friends)
            arr.push(friend);
        friendList.dataSource.data = arr;
    }

    @:bind(actionNotificationCallbackButton, MouseEvent.CLICK)
    private function onActionNotificationCallback(_) {
        //actionNotificationCallbackLabel.text = "";
        trace("ggg");
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
        trace("You chose " + actionData.text + "!");
        //actionNotificationCallbackLabel.text = "You chose " + actionData.text + "!";
        return true; // return value indicates if the notification should close or not
    }

    private function joinLobby(lobbyId){
        var lobbyInfo = getLobbyInfo(lobbyId);
        trace(lobbyInfo);
        var lobbyWindow:LobbyWindow = new LobbyWindow();
        lobbyWindow.setLobbyInfo(lobbyInfo);
        this.addComponent(lobbyWindow);
    }
    private function getLobbyInfo(lobbyId){
        //Make api call or something to get info
        var lobbyInfo = {
            lobbyId: "YUFhkw3423",
            players: [
                {nickName:"Nagib19", playerId:"ruewi4389rr", selectedRace:"None", lobbySpot:1, rating:"345", rank:"Soldier"},
                {nickName:"You", playerId:"Qrt5E32e", selectedRace:"Goblin/Elf", lobbySpot:2, rating:"1140", rank:"Colonel"},
            ],
            hostId:"ruewi4389rr",
            rules:"Standard rules",
            lobbyCapacity:6,
            gameMode:"2x2x2"
        }
        return lobbyInfo;
    }
}