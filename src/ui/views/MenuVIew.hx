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

    private var client:Client = null;
    private var room: Room<State>;
    //var playerEntities:
    var endpoint = "ws://localhost:2567";
    var lobby:Room;
    var allRooms:Array<Room>;
        // we will assign each player visual representation here
    // by their `sessionId`
    var playerEntities:Map<String,TestEntity> = new Map<String,TestEntity>();// {[sessionId: string]: any} = {};
    var currentPlayer: TestEntity;

    function onjoin() {
        lobby.onMessage("rooms", (rooms) => {
            allRooms = rooms;
            update_full_list();

            console.log("Received full list of rooms:", allRooms);
        });

        lobby.onMessage("+", ([roomId, room]) => {
            const roomIndex = allRooms.findIndex((room) => room.roomId === roomId);
            if (roomIndex !== -1) {
                console.log("Room update:", room);
                allRooms[roomIndex] = room;

            } else {
                console.log("New room", room);
                allRooms.push(room);
            }
            update_full_list();
        });

        lobby.onMessage("-", (roomId) => {
            console.log("Room removed", roomId);
            allRooms = allRooms.filter((room) => room.roomId !== roomId);
            update_full_list();
        });

        lobby.onLeave(() => {
            allRooms = [];
            update_full_list();
            console.log("Bye, bye!");
        });
    }

    function join () {
        // Logged into your app and Facebook.
        client.joinOrCreate("lobby").then(room_instance => {
            lobby = room_instance;
            onjoin();
            console.log("Joined lobby room!");

        }).catch(e => {
            console.error("Error", e);
        });
      }

    public function new() {
        super();
        client = new Client("localhost",2567);
        //joinLobby("fddsfsd3223");
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
   
    function leave() {
        if (lobby) {
          lobby.leave();

        } else {
          console.warn("Not connected.");
        }
      }

    function update_full_list() {
        var el = document.getElementById('all_rooms');
        el.innerHTML = allRooms.map(function(room) {
            return "<li><code>" + JSON.stringify(room) + "</code></li>";
        }).join("\n");

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

    @:bind(quickMatchBtn, MouseEvent.CLICK)
    private function onQuickMatchClick(e){
        client.joinOrCreate("lobby", [], State, function(err:MatchMakeError, room:Room<State>) {
            lobby = room;
            onjoin();
            console.log("Joined lobby room!");
        });
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