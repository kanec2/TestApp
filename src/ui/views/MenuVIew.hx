package ui.views;

import haxe.ui.events.MenuEvent;
import model.AppData;
import ui.components.LobbyList;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import ui.components.SignInWindow;
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
    var signed:Bool;
    var appData:AppData;
    public var signedIn(get,set):Bool;
    
    /**
     * [Menu handlers]
     */
    //#region listeners
    
    @:bind(profileButton,MouseEvent.CLICK)
    private function onProfileButtonClick(e){
        if(signedIn == false){
            showSignInWindow();
        }
        else {
            //showAccountSettingsWindow();
        }
    }

    //#endregion
    private var _currentDotIndex:Int = 0;
    
    /*@:bind(quickMatchButton, MouseEvent.CLICK)
    private function onPrev(_) {
        
        var newIndex = _currentDotIndex - 1;
        if (newIndex < 0) {
            newIndex = theDots.childComponents.length - 1;
        }
        setDotIndex(newIndex);
    }*/
    private function setHighlight(idx){
        trace("well");
        trace(idx);
    }
    /*@:bind(buttonNext, MouseEvent.CLICK)
    private function onNext(_) {
        var newIndex = _currentDotIndex + 1;
        if (newIndex > theDots.childComponents.length - 1) {
            newIndex = 0;
        }
        setDotIndex(newIndex);
    }
    
    private function setDotIndex(index:Int) {
        theDots.childComponents[_currentDotIndex].swapClass(':shrink', ':grow', true, true);
        _currentDotIndex = index;
        theDots.childComponents[_currentDotIndex].swapClass(':grow', ':shrink', true, true);
    }*/

    //onMenuSelected:MenuEvent->Void
    @:bind(topBar,MenuEvent.MENU_SELECTED)
    function menuSelectionChanged(e:MenuEvent){
        //switch(e)
        //quickMatchButton.
        trace(e.menu.userData);
        trace(e.menuItem);
        trace("changed");
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
        //client = new Client(endpoint);
        appData = new AppData(endpoint);
        client = appData.client;
        /*
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
*/
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
    
    function get_signedIn():Bool {
		return signed;
	}

	function set_signedIn(value:Bool):Bool {
        profileButton.hide();
        profileMenu.show();
		signed = value;
        return signed;
	}

    function showSignInWindow(){
        var dialog = new SignInWindow();
        dialog.onDialogClosed = function(e:DialogEvent) {
            signedIn = dialog.validationResult;
            trace(signedIn);
        }
        dialog.showDialog();
    }
/*
    @:bind(profileButton,MouseEvent.CLICK)
    private function onProfileButtonClick(e){
        
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
        //friendList.dataSource.data = friends;
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