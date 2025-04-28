import { MapSchema,Schema, Context, type } from "@colyseus/schema";
import { LobbyPlayer } from "./LobbyPlayer";

export class TeamLobby extends Schema {
  @type({ map: LobbyPlayer }) players = new MapSchema<LobbyPlayer>();
  @type("number") numTeams: number;
  @type("string") gameMode: string;
  @type("string") hostId: string;
  
}