package ui.components;

import haxe.ui.events.ItemEvent;
import haxe.ui.containers.VBox;

using itertools.Extensions;
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

    private function emptyTeam(i:Int){
        var teamColor = switch(i){
            case 0: "black";
            case 1: "blue";
            case 2: "red";
            case 3: "yellow";
            default : "black";
        }
    }
    private function emptyTeamName(i:Int){
        var teamName = switch(i){
            case 0: "Black team";
            case 1: "Blue team";
            case 2: "Red team";
            case 3: "Yellow team";
            default : "Black team";
        }
    }
    private function emptyLobbyPlayer(spot:Int = 0){
        return {
            userName:"None",
            firstName:"",
            lastName:"",
            active:true,
            lobbySpot:spot
        };
    }
    
	public function setLobbyInfo(lobbyInfo:api.models.JsonModels.LobbyData) {
		lv1.dataSource.clear();
        var gameModeString = lobbyInfo.gameMode;
        var gameMode = switch(gameModeString){
            case "2x2" | "2x2x2" | "2x2x2x2" : "team";
            default : "free";
        };

        //username="ianharrigan" firstName="Ian" lastName="Harrigan" active="true"
        var numPlayers = lobbyInfo.lobbyCapacity;
        var players = lobbyInfo.players;

        if(gameMode == "team"){
            var numTeams = switch(gameModeString){
                case "2x2" : 2;
                case "2x2x2" : 3;
                case "2x2x2x2" : 4;
                default : 2;
            };
            var teams = players.groupBy(x -> x.team).toMapProj(g->g.key, g -> g.values.toArray()).sort();
            var sortedTeams:SortedStringMap<Array<LobbyUser>> = new SortedStringMap<Array<LobbyUser>>();
            for(key in teams.keys()){
                var value = teams.get(key);
                sortedTeams.set(key,value);
            }
            var teamNames = sortedTeams.keys();
            var teamLobbyData:{
                teams:Array<{teamName:String, teamColor:String, teamPlayers:Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}> }>,
                rules:String,
                hostId:String,
                lobbyCapacity:Int,
                gameMode:String,
                numTeams:Int,
                lobbyId:String
            }
            teamLobbyData.rules = lobbyInfo.rules;
            teamLobbyData.hostId = lobbyInfo.hostId;
            teamLobbyData.lobbyCapacity = lobbyInfo.lobbyCapacity;
            teamLobbyData.gameMode = lobbyInfo.gameMode;
            teamLobbyData.numTeams = numTeams;
            teamLobbyData.lobbyId = lobbyInfo.lobbyId;

            var lobbyTeamData = new Array<{teamName:String, teamColor:String, teamPlayers:Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}> }>

            for(i in 0...numTeams){
                var teamName = teamNames[i] ?? emptyTeamName(i);
                var teamColor = teamNames[i].replaceAll(" team","").toLowerCase();
                var teamPlayers = teamNames[i] != null ? teams.get(teamName) : new Array<LobbyUser>();
                var teamLobbyPlayers = new Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}>();
                for(j in 0...2){
                    var playerItem = transformLobbyPlayerItem(teamPlayers[j]) ?? emptyLobbyPlayer(j);
                    teamLobbyPlayers.push(playerItem);
                }
                var team = {
                    teamName:teamName,
                    teamColor: teamColor,
                    teamPlayers: teamLobbyPlayers
                }

            }
            //dataSource = lobbyTeamData;
        }
        else {
            var newData = new Array<{userName:String, firstName:String, lastName:String, active:Bool}>();
            for(i in 0...numPlayers){
                var playerItem = transformLobbyPlayerItem(players[i]) ?? emptyLobbyPlayer();
                newData.push(playerItem);
            }
            lv1.dataSource.data = newData;
        }
	}
    /*
    function transformLobbyTeamItem(lobby:{color:}) {
        if(player == null) return null;
		return {
            userName:player.nickName,
            firstName:player.playerId,
            lastName:player.selectedRace,
            active:true
        };
	}*/

	function transformLobbyPlayerItem(player:api.models.JsonModels.LobbyUser) {
        if(player == null) return null;
		return {
            userName:player.nickName,
            firstName:player.playerId,
            lastName:player.selectedRace,
            active:true,
            lobbySpot:player.lobbySpot
        };
	}
}