package ui.views;

import network.states.LobbyState;
import io.colyseus.events.EventHandler;
import io.colyseus.Room;
import io.colyseus.Client;
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
    private var room: Room<Dynamic>;
    //var playerEntities:
    var endpoint = "ws://localhost:2567";
    var lobby:Room<Dynamic>;
    var allRooms:Array<Room<Dynamic>>;
        // we will assign each player visual representation here
    // by their `sessionId`
    var playerEntities:Map<String,TestEntity> = new Map<String,TestEntity>();// {[sessionId: string]: any} = {};
    var currentPlayer: TestEntity;

    function leaveHandler(){

    }
    
    function onjoin() {
        lobby.onMessage("rooms", (rooms) -> {
            allRooms = rooms;
            //update_full_list();

            trace("Received full list of rooms:", allRooms);
        });

        lobby.onMessage("+", (data) -> {
            var roomId = data.roomId;
            var room = data.room;
            var roomIndex = -1;
            var i = 0;
            for(r in allRooms){ 
                if (r.roomId == roomId) {
                    roomIndex = i;
                    break;
                }
                i++;
            }
            //var roomIndex = allRooms.findIndex((room) -> room.roomId == roomId);
            if (roomIndex != -1) {
                trace("Room update:", room);
                allRooms[roomIndex] = room;

            } else {
                trace("New room", room);
                allRooms.push(room);
            }
            //update_full_list();
        });
        //lobby.send("assign player", )
        lobby.onMessage("-", (roomId) -> {
            trace("Room removed", roomId);
            allRooms = allRooms.filter((room) -> room.roomId != roomId);
            //update_full_list();
        });
        
        //lobby.onLeave = leaveHandler;
        /*
        lobby.onLeave = () ->{
            allRooms = [];
            //update_full_list();
            trace("Bye, bye!");
        }*/
        /*lobby.onLeave(() -> {
            allRooms = [];
            //update_full_list();
            trace("Bye, bye!");
        });*/
    }

    /*function join () {
        // Logged into your app and Facebook.
        client.joinOrCreate("lobby").then(room_instance -> {
            lobby = room_instance;
            onjoin();
            trace("Joined lobby room!");

        }).catch(e => {
            trace("Error", e);
        });
      }*/

    public function new() {
        super();
        client = new Client("localhost",2567);
        
        client.joinOrCreate("lobby",[],LobbyState,(err, rom) ->{
            if(err != null) trace(err);
            if(rom != null) {
                trace(rom.roomId);
                trace(rom.state);
                //lobby = rom;
                //onjoin();
                //rom.onMessage("+", ())
            }
        });

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
    /*
    function leave() {
        if (lobby) {
          lobby.leave();

        } else {
          trace("Not connected.");
        }
      }
      */
/*
    function update_full_list() {
        var el = document.getElementById('all_rooms');
        el.innerHTML = allRooms.map(function(room) {
            return "<li><code>" + JSON.stringify(room) + "</code></li>";
        }).join("\n");

      }*/

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
        // client.joinOrCreate("lobby", [], Dynamic, function(err:MatchMakeError, room:Room<Dynamic>) {
        //     lobby = room;
        //     onjoin();
        //     trace("Joined lobby room!");
        // });
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