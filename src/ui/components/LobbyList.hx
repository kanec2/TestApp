package ui.components;

import io.colyseus.Client;
import model.Settings;
import model.AppData;
import haxe.ui.containers.VBox;

typedef SelectedFilter = {
    gameModes: Map<String, Bool>,
    gameMaps: Map<String, Bool>
  }
  @:xml('
  <vbox width="100%" style="padding:10px;">
    <style>
        #myCustomTabView .tabbar-button {
            font-weight: bold;
        }

        #myCustomTabView .tabview-content {
            padding: 1px;
        }

        #myCustomTabView #redTabButton {
            color: red;
        }
        #myCustomTabView #greenTabButton {
            color: green;
        }
        #myCustomTabView #blueTabButton {
            color: blue;
        }

        #myCustomTabView #redTabButton.tabbar-button-selected {
            border-top-color: red;
            border-bottom-color: #FFEEEE;
            background-color: #FFEEEE;
        }
        #myCustomTabView #greenTabButton.tabbar-button-selected {
            border-top-color: green;
            border-bottom-color: #EEFFEE;
            background-color: #EEFFEE;
        }
        #myCustomTabView #blueTabButton.tabbar-button-selected {
            border-top-color: blue;
            border-bottom-color: #EEEEFF;
            background-color: #EEEEFF;
        }
    </style>

    <tabview id="myCustomTabView" width="300" height="100" styleName="rounded-tabs full-width-buttons">
        <box id="red" width="100%" height="100%" text="Red" style="background-color: #FFEEEE" />
        <box id="green" width="100%" height="100%" text="Green" style="background-color: #EEFFEE" />
        <box id="blue" width="100%" height="100%" text="Blue" style="background-color: #EEEEFF" />
    </tabview>
</vbox>
  ')
class LobbyList extends VBox{
    var gameModes: Map<String, Bool> = new Map<String, Bool>();
    var rooms:Array<RoomAvailable>; //RoomAvailable
    public function new(appData: AppData) {
        super();
        
        for (mode in Settings.GAME_MODES) {
          gameModes.set(mode, true);
        }

        var client:Client = appData.client;
        client.getAvailableRooms("team_lobby",(err, serverRooms)->{
            for(room in serverRooms){
                rooms.push(room);
            }
        });
    }

    function joinRoom(roomId:String){
        
    }
}