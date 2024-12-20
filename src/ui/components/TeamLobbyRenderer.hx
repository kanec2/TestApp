package ui.components;

import haxe.ui.components.Image;
import haxe.ui.util.Color;
import haxe.ui.core.ItemRenderer;

using hx.strings.Strings;
@:xml('
<item-renderer width="100" height="100">
    <label id="teamNameLabel" width = "100%" textAlign="left"/>
    <listview id="teamLobbyList" selectedIndex="0">
        <my-list-view-item-renderer style="background-color: #009F42;border:1px solid #009F42;background-opacity: .1;"/>
    </listview>
</item-renderer>
')
class TeamLobbyRenderer extends ItemRenderer {
    
    private override function onDataChanged(data:Dynamic) {
        super.onDataChanged(data);
        if (data == null) { // TODO: should change call so onDataChange only ever gets called when non-null
            return;
        }
        //hx.strings.
        
        
        var playerTeam:String = data.players[0].team;
        var teamColor:String = playerTeam.replaceAll(" team","").toLowerCase();
        teamNameLabel.text = data.playerTeam;
        teamNameLabel.style.color = Color.fromString(teamColor);
        //nickName.text = data.nickName;
        teamLobbyList.dataSource = data.players;
        /*
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