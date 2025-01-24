import { Server } from "colyseus";

import express from "express";
import {IncomingMessage} from "http";
import { Room, Client } from "colyseus";
import { TeamLobbyPlayer, LobbyTeam, TeamLobbyState } from "./schema/TeamLobbyState";
import { JWT } from "@colyseus/auth";

// Define the TeamLobbyRoom
export class TeamLobbyRoom extends Room<TeamLobbyState> {
    // Store the teams and player data
    
    //private teams: { [key: string]: Client[] } = {};
    //private playerNames: { [key: string]: string } = {};
    static async onAuth(token: string, req: IncomingMessage) {
        console.log("COOKIE:", req.headers.cookie);
        return (token) ? await JWT.verify(token) : { guest: true };
      }
    onCreate(options: any) {
        let numTeams = 2;
        switch (options.gameMode) {
            case "2x2x2": numTeams = 3; break;
            case "2x2x2x2": numTeams = 4; break;
            default: numTeams = 2; break;
        }
        this.setState(new TeamLobbyState());
        console.log("Team Lobby Room created with options:", options);
        this.initializeTeams(numTeams);
        
        this.onMessage("joinTeam", (client: Client) => {
            this.addPlayerToTeam(client);
        });
        
        this.onMessage("leaveTeam", (client: Client) => {
            this.removePlayerFromTeam(client);
        });
    }

    private getPlayerData = (clientId:string)=>{
        let playerData = {
            nickName: "Dido",
            rank: "Colonel",
            rating: 136
        }
        return playerData;
    }

    onJoin(client: Client, options: any) {
        console.log(`Client ${client.sessionId} joined!`);
        console.log(client.auth);
        const playerData = this.getPlayerData(client.id);
        const player:TeamLobbyPlayer = new TeamLobbyPlayer();
        player.nickName = playerData.nickName;
        player.rank = playerData.rank;
        player.rating = playerData.rating;
        player.selectedRace = "none";
        player.team = "none";
        this.state.players.set(client.sessionId, player);
        this.addPlayerToTeam(client);

        // Optionally send welcome message or initial state
        /*this.send(client, {
            message: `Welcome to the lobby! Choose your team.`,
            teams: this.teams,
        });*/
    }

    onLeave(client: Client) {
        console.log(`Client ${client.sessionId} left!`);
        this.removePlayerFromTeam(client);
    }

    onDispose() {
        console.log("Team Lobby Room disposed!");
    }

    private initializeTeams(numTeams: number) {
        // Initialize teams based on the number of teams specified
        for (let i = 0; i < numTeams; i++) {
            let teamName = "";
            let teamColor = "";
            switch (i) {
                case 0: teamName = "Red Team"; teamColor = "Red"; break;
                case 1: teamName = "Blue Team"; teamColor = "Blue"; break;
                case 2: teamName = "Yellow Team"; teamColor = "Yellow"; break;
                case 3: teamName = "Green Team"; teamColor = "Green"; break;
            }
            
            const team = new LobbyTeam();
            team.teamColor = teamColor;
            team.teamName = teamName;
            team.numPlayers = 0;
            this.state.teams.set(teamColor,team);
            //this.state.teams[`team${i + 1}`] = [];
        }
    }
    private assignPlayerToTeam(client: Client){

    }
    private addPlayerToTeam(client: Client) {
        // Find the team with the least players
        const teamKeys = Object.keys(this.state.teams);
        const smallestTeamKey = teamKeys.reduce((smallest, key) =>
            this.state.teams.get(smallest).numPlayers <= this.state.teams.get(key).numPlayers ? smallest : key
        );
        const player = this.state.players.get(client.sessionId);
        const smallestTeam = this.state.teams.get(smallestTeamKey);

        smallestTeam.numPlayers++;
        player.team = smallestTeam.teamName;

        let teamFreeMinSpot = 999;
        this.state.players.forEach(element => {
            if(element != player && element.team == smallestTeam.teamName && element.teamSpot < teamFreeMinSpot){
                teamFreeMinSpot = element.teamSpot;
            }
        }); 
        player.teamSpot = teamFreeMinSpot;
    }

    private removePlayerFromTeam(client: Client) {
        // Remove player from their team
        const playerToKick:TeamLobbyPlayer = this.state.players.get(client.sessionId);

        const playerTeam = playerToKick.team;
        this.state.teams.get(playerTeam).numPlayers--;

        
    }
}