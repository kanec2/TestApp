import { MapSchema,Schema, Context, type } from "@colyseus/schema";


export class TeamLobbyPlayer extends Schema {
    @type("string") nickName: string;
    @type("string") playerId: string;
    @type("string") selectedRace: string;
    @type("number") teamSpot: number;
    @type("number") rating: number;
    @type("string") rank: string;
    @type("string") team : string;
  }
export class LobbyTeam extends Schema {
  @type("string") teamName : string;
  @type("string") teamColor: string;
  @type("number") numPlayers: number;
}
export class TeamLobbyState extends Schema {
    @type("string") gameMode: string;
    @type("number") lobbyCapacity: number;
    @type({ map: TeamLobbyPlayer }) players = new MapSchema<TeamLobbyPlayer>();
    @type({ map: LobbyTeam }) teams = new MapSchema<LobbyTeam>();
    @type("boolean") isPublic:boolean;
    //private teams: { [key: string]: Client[] } = {};
}