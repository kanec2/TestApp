package ui.components;

import haxe.ui.components.Image;
import haxe.ui.util.Color;
import haxe.ui.core.ItemRenderer;

using hx.strings.Strings;
@:xml('
<item-renderer width="100%">
<vbox width="100%" >
    <label id="teamNameLabel" width = "100%" textAlign="left"/>
    <vbox id="teamLobbyList" width="100%">
        <lobby-player-renderer padding="5" style="background-color: #009F42;border:1px solid #009F42;background-opacity: .1;"/>
    </vbox>
    
    </vbox>
</item-renderer>
')
class TeamLobbyRenderer extends ItemRenderer {
    //data: new Array<{teamName:String, teamColor:String, teamPlayers:Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}> }>();
            
    private override function onDataChanged(data:Dynamic) {
        super.onDataChanged(data);
        if (data == null) { // TODO: should change call so onDataChange only ever gets called when non-null
            return;
        }
        //hx.strings.
        var color = Color.fromString(data.teamColor);
        teamNameLabel.style.backgroundColor = color;//Color.fromString(data.teamColor);
        teamNameLabel.text = data.teamName;
        teamLobbyList.dataSource.data = data.teamPlayers;
        trace(color);
        //trace(data.teamColor);
        
        //var playerTeam:String = data.players[0].team;
        //var teamColor:String = playerTeam.replaceAll(" team","").toLowerCase();
        //teamNameLabel.text = data.playerTeam;
        //teamNameLabel.style.color = Color.fromString(teamColor);
        //nickName.text = data.nickName;
        //teamLobbyList.dataSource = data.players;
        /*
        <listview id="teamLobbyList" width = "100%" selectedIndex="0">
            <my-list-view-item-renderer style="background-color: #009F42;border:1px solid #009F42;background-opacity: .1;"/>
        </listview>
        if (data.image == null)
            profileImage.resource = "assets/images/profile_placeholder.png";
        else 
            profileImage.resource = data.image; //data.profileImageUrl;
        if (data.active == "true") { // TODO: need to autoconvert basic types (this used to work!)
            statusLabel.text = "online";
            statusLabel.backgroundColor = Color.fromString("green");
            //theButton.text = "expel";
        } else {
            statusLabel.text = "offline";
            statusLabel.backgroundColor = Color.fromString("red");
            //profileImage.resource = "assets/images/select_some_11.png";
            //theButton.text = "Activate";
        }*/
    }
}