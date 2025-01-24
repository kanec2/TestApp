import { Schema, type } from "@colyseus/schema";
import { Client, LobbyRoom, Room } from "colyseus";
import { CustomLobbyState, LobbyPlayer } from "./schema/CustomLobbyState";

export class CustomLobbyRoom extends Room<CustomLobbyState> {
    onCreate(options: any) {
        //this.autoDispose = false;
        
        this.setState(new CustomLobbyState());
        console.log("Lobby created!", options);

        // Handle client messages
        this.onMessage("joinLobby", (client: Client, message: any) => {
            this.addPlayer(client);
        });

        this.onMessage("leaveLobby", (client: Client) => {
            this.removePlayer(client);
        });
        
    }

    onJoin(client: Client, options: any) {
        
        console.log(client.sessionId, "joined!",new Date());
        this.addPlayer(client);
    }

    onLeave(client: Client) {
        console.log(client.sessionId, "left!",new Date());
        this.allowReconnection(client,60*30);
        this.removePlayer(client);
    }
    
    onDispose() {
        console.log("Lobby disposed!");
    }

    addPlayer(client: Client) {
        const playerId = client.sessionId;
        const clientUid = client.id;
        const player:LobbyPlayer = new LobbyPlayer();
        player.nickName = "john";
        player.lobbySpot = 1;
        player.playerId = clientUid;
        player.rank = "Colonel";
        player.rating = 120;
        player.selectedRace = "none";
        this.state.players.set(playerId, player);
        /*this.state.players[playerId] = {
            name: message.name,
            // You can store other player data here
        };
        this.broadcast("playerJoined", this.state.players[playerId]);*/
    }

    removePlayer(client: Client) {
        const playerId = client.sessionId;

        this.state.players.delete(playerId);
        //this.broadcast("playerLeft", playerId);
    }
}