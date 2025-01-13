import { MapSchema,Schema, Context, type } from "@colyseus/schema";

export class LobbyPlayer extends Schema {
    @type("string") nickName: string;
    @type("string") playerId: string;
    @type("string") selectedRace: string;
    @type("number") lobbySpot: number;
    @type("number") rating: number;
    @type("string") rank: string;
  }

export class CustomLobbyState extends Schema {
    @type("string") gameMode: string;
    @type("number") lobbyCapacity: number;
    @type({ map: LobbyPlayer }) players = new MapSchema<LobbyPlayer>();
    @type("boolean") isPublic:boolean;
    //private teams: { [key: string]: Client[] } = {};
}