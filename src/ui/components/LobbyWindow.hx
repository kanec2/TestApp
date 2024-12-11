package ui.components;

import haxe.ui.events.ItemEvent;
import haxe.ui.containers.VBox;
@:build(haxe.ui.ComponentBuilder.build("assets/ui/components/lobby-window.xml"))
class LobbyWindow extends VBox {
    public function new() {
        super();
    }
    @:bind(lv1, ItemEvent.COMPONENT_CLICK_EVENT)
    private function onItemEventClick(event:ItemEvent) {
        var item = lv1.dataSource.get(event.itemIndex);
        switch (event.sourceEvent.target.id) {
            case "theButton":
                if (event.sourceEvent.target.text == "Activate") {
                    item.active = "true";
                } else if (event.sourceEvent.target.text == "Deactivate") {
                    item.active = "false";
                }
                lv1.dataSource.update(event.itemIndex, item);
                lv1.invalidateComponentData();
            case "theDeleteButton":
                lv1.dataSource.removeAt(event.itemIndex);
                lv1.invalidateComponentData();
        }
    }
    private function emptyLobbyPlayer(){
        return {
            userName:"None",
            firstName:"",
            lastName:"",
            active:true
        };
    }
    
	public function setLobbyInfo(lobbyInfo:{lobbyId:String, players:Array<{nickName:String, playerId:String, selectedRace:String, lobbySpot:Int, rating:String, rank:String}>, hostId:String, rules:String, lobbyCapacity:Int, gameMode:String}) {
		lv1.dataSource.clear();
        //username="ianharrigan" firstName="Ian" lastName="Harrigan" active="true"
        var numPlayers = lobbyInfo.lobbyCapacity;
        var players = lobbyInfo.players;
        var newData = new Array<{userName:String, firstName:String, lastName:String, active:Bool}>();
        for(i in 0...numPlayers){
            var playerItem = transformLobbyItem(players[i]) ?? emptyLobbyPlayer();
            newData.push(playerItem);
        }
        /*
        var x = {
            userName:"dsa",
            firstName:"zxc",
            lastName:"bcv",
            active:true
        };*/
        //newData.push(x);
        lv1.dataSource.data = newData;
	}

	function transformLobbyItem(player:{nickName:String, playerId:String, selectedRace:String, lobbySpot:Int, rating:String, rank:String}) {
        if(player == null) return null;
		return {
            userName:player.nickName,
            firstName:player.playerId,
            lastName:player.selectedRace,
            active:true
        };
	}
}