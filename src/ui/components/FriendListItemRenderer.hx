package ui.components;

import haxe.ui.util.Color;
import haxe.ui.core.ItemRenderer;

@:xml('
<item-renderer width="100%" layout="horizontal">
    <image id="profileImage" verticalAlign="center" />
    <label id="nickName" width="100%" verticalAlign="center" />
    <label id="statusLabel" width="100%" verticalAlign="center" style="color:white;" />
    <button id="chatButton" width="20" />
    <button id="inviteButton" width="20" />
    <button id="deleteButton" width="20" />
</item-renderer>
')
class FriendListItemRenderer extends ItemRenderer {
    
    private override function onDataChanged(data:Dynamic) {
        super.onDataChanged(data);
        if (data == null) { // TODO: should change call so onDataChange only ever gets called when non-null
            return;
        }

        //var fullName = data.firstName + " " + data.lastName + " (" + data.username + ")";
        nickName.text = data.nickName;
        var profile = data.profileImg;
        if (profile == null)
            profile = "assets/images/profile_placeholder.png";
        profileImage.resource = profile;
        if (data.active == "true") { // TODO: need to autoconvert basic types (this used to work!)
            statusLabel.text = "online";
            statusLabel.backgroundColor = Color.fromString("green");
            //theButton.text = "expel";
        } else {
            statusLabel.text = "offline";
            statusLabel.backgroundColor = Color.fromString("red");
            //profileImage.resource = "assets/images/select_some_11.png";
            //theButton.text = "Activate";
        }
    }
}