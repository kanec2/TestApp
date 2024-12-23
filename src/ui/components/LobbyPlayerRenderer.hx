package ui.components;
import haxe.ui.util.Color;
import haxe.ui.core.ItemRenderer;

@:xml('
<item-renderer width="100%" layout="horizontal">
    <image id="theIcon"  verticalAlign="center" />
    <label id="theLabel" width="100%" verticalAlign="center" />
    <button id="theButton" width="90" />
</item-renderer>
')
class LobbyPlayerRenderer extends ItemRenderer {
    //data: new Array<{teamName:String, teamColor:String, teamPlayers:Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}> }>();
            
    private override function onDataChanged(data:Dynamic) {
        super.onDataChanged(data);
        if (data == null) { // TODO: should change call so onDataChange only ever gets called when non-null
            return;
        }

        var fullName = data.firstName + " " + data.lastName + " (" + data.username + ")";
        theLabel.text = fullName;

        if (data.active == "true") { // TODO: need to autoconvert basic types (this used to work!)
            theIcon.resource = "assets/images/select_none_11.png";
            theButton.text = "expel";

        } else {
            theIcon.resource = "assets/images/select_some_11.png";
            theButton.text = "Activate";
        }
    }
}