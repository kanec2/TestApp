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
    <vbox width="100%" height="100%">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f0f0;
        }

        .header {
            background-color: #4CAF50;
            padding: 3px;
        }
        .header-label{
            color: white;
            text-align: center;
            font-bold: true;
            font-size: 20px;
        }

        .container {

            /*margin: 20px auto;*/
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
        }

        .lobby-item {
            /*display: flex;*/
            justify-content: space-between;
            align-items: center;
            /*padding: 10px;*/
            border-bottom: 1px solid #ddd;
        }

        .lobby-item:last-child {
            border-bottom: none;
        }

        .lobby-name {
            font-size: 18px;
            font-bold: true;
        }

        .lobby-status {
            font-size: 14px;
            color: #555;
        }

        .join-button {
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 8px 12px;
            cursor: pointer;
            transition: background 0.3s;
        }

        .join-button:hover {
            background-color: #45a049;
        }
        .join-button:disabled {
            background-color: #2f2c27;
        }
    </style>
        <box styleName="header" width="100%">
            <label width="100%" styleName="header-label" text="Lobby List"/>
        </box>

        <vbox styleName="container" width="100%" height="100%">
            <item-renderer width="100%">
                <hbox styleName="lobby-item" width="100%">
                    <vbox>
                        <label id="lobbyName" styleName="lobby-name"/>
                        <label id="lobbyStatus" styleName="lobby-status"/>
                    </vbox>
                    <button width="100px" id="joinButton" text="Join" styleName="join-button"/>
                </hbox>
            </item-renderer>
            <data>
                <item lobbyName="Casual Game" lobbyStatus="5/10 players" />
                <item lobbyName="Tournament Lobby" lobbyStatus="2/6 players"/>
                <item lobbyName="Practice Room" lobbyStatus="8/8 players" joinButton = "Full" joinButton.disabled = "${true}" />
            </data>
        </vbox>
    </vbox>
  ')
class LobbyList extends VBox{
    var gameModes: Map<String, Bool> = new Map<String, Bool>();
    var rooms:Array<RoomAvailable>; //RoomAvailable
    public function new() {
        super();
        
        for (mode in Settings.GAME_MODES) {
          gameModes.set(mode, true);
        }
        /*
        var client:Client = appData.client;
        client.getAvailableRooms("team_lobby",(err, serverRooms)->{
            if(err != null){
                
            }
            if(serverRooms != null){
                for(room in serverRooms){
                    rooms.push(room);
                }
            }
        });*/
    }

    function joinRoom(roomId:String){
        
    }
}