package ui.components;

import Main.TeamLobbyData;
import api.models.JsonModels.LobbyUser;
import haxe.ui.events.ItemEvent;
import haxe.ui.containers.VBox;
import hx.strings.collection.SortedStringMap;
using itertools.Extensions;
using hx.strings.Strings;
@:build(haxe.ui.ComponentBuilder.build("assets/ui/components/lobby-window.xml"))
class LobbyWindow extends VBox {
    public function new() {
        super();
    }
    /*
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
    */
    private function emptyTeam(i:Int){
        var teamColor = switch(i){
            case 0: "orange";
            case 1: "blue";
            case 2: "red";
            case 3: "yellow";
            default : "orange";
        }
        return teamColor;
    }
    private function emptyTeamName(i:Int){
        var teamName = switch(i){
            case 0: "Orange team";
            case 1: "Blue team";
            case 2: "Red team";
            case 3: "Yellow team";
            default : "Orange team";
        }
        return teamName;
    }
    private function emptyLobbyPlayer(spot:Int = 0){
        return {
            nickName:"None",
            firstName:"",
            lastName:"",
            active:true,
            lobbySpot:spot,
            team:""
        };
    }
    
	public function setLobbyInfo(lobbyInfo:api.models.JsonModels.LobbyData) {
		//lv1.dataSource.clear();
        var gameModeString = lobbyInfo.gameMode;
        var gameMode = switch(gameModeString){
            case "2x2" | "2x2x2" | "2x2x2x2" : "team";
            default : "free";
        };
        trace("Game mode: "+gameMode);
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
            trace("Num teams: "+numTeams);
            var teams = players.groupBy(x -> x.team).toMapProj(g->g.key, g -> g.values.toArray());//.sort();
            var sortedTeams:SortedStringMap<Array<LobbyUser>> = new SortedStringMap<Array<LobbyUser>>();
            var teamNames:Array<String> = new Array<String>();
            for(key in teams.keys()){
                var value = teams.get(key);
                sortedTeams.set(key,value);
            }
            for(key in sortedTeams.keys()){
                teamNames.push(key);
            }
            var teamLobbyData:TeamLobbyData = {
                teams:null,
                rules:"",
                hostId:"",
                lobbyCapacity:0,
                gameMode:"",
                numTeams:0,
                lobbyId:""
            };
            teamLobbyData.rules = lobbyInfo.rules;
            teamLobbyData.hostId = lobbyInfo.hostId;
            teamLobbyData.lobbyCapacity = lobbyInfo.lobbyCapacity;
            teamLobbyData.gameMode = lobbyInfo.gameMode;
            teamLobbyData.numTeams = numTeams;
            teamLobbyData.lobbyId = lobbyInfo.lobbyId;

            var lobbyTeamData = new Array<{
                teamName:String, 
                teamColor:String, 
                teamPlayers:Array<{
                    nickName:String, 
                    firstName:String, 
                    lastName:String, 
                    active:Bool,
                    team:String,
                    lobbySpot:Int}> 
                }>();
            
            for(i in 0...numTeams+1){
                var nameToFind = emptyTeamName(i);
                var founded = false;
                for(tdata in lobbyTeamData){
                    if(tdata.teamName==nameToFind){
                        founded = true;
                        break;
                    }
                }
                if(founded==true) continue;
                var teamName = teamNames[i] ?? nameToFind;
                var teamColor = teamName.replaceAll(" team","").toLowerCase();
                var teamPlayers = teamName != null ? teams.get(teamName) : new Array<LobbyUser>();
                var teamLobbyPlayers = new Array<{nickName:String, firstName:String, lastName:String, active:Bool,team:String,lobbySpot:Int}>();
                for(j in 0...2){
                    var playerItem:{
                        nickName:String, 
                        firstName:String, 
                        lastName:String, 
                        active:Bool,
                        team:String,
                        lobbySpot:Int
                    };
                    
                    playerItem = emptyLobbyPlayer(j);
                    if(teamPlayers != null && teamPlayers.length > j)
                        playerItem =  transformLobbyPlayerItem(teamPlayers[j]);
                    //trace(teamPlayers[j]);
                    //if(teamPlayers != null && teamPlayers[i]!=null) playerItem =  transformLobbyPlayerItem(teamPlayers[j]);
                    trace(playerItem);
                    playerItem.team = teamName;
                    teamLobbyPlayers.push(playerItem);
                }
                var team = {
                    teamName:teamName,
                    teamColor: teamColor,
                    teamPlayers: teamLobbyPlayers
                }
                lobbyTeamData.push(team);
                
            }
            trace(lobbyTeamData);
            //teamLobbyData.teams = lobbyTeamData;
            var teamLobbyRenderer = new TeamLobbyRenderer();
            lobbyBox.itemRenderer = teamLobbyRenderer;
            lobbyBox.dataSource.data = lobbyTeamData;
            //dataSource = lobbyTeamData;
        }
        else {
            var newData = new Array<{nickName:String, firstName:String, lastName:String, active:Bool,team:String}>();
            for(i in 0...numPlayers){
                var playerItem = transformLobbyPlayerItem(players[i]) ?? emptyLobbyPlayer();
                newData.push(playerItem);
            }
            //lv1.dataSource.data = newData;
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
            nickName:player.nickName,
            firstName:player.playerId,
            lastName:player.selectedRace,
            active:true,
            lobbySpot:player.lobbySpot,
            team:player.team
        };
	}
}