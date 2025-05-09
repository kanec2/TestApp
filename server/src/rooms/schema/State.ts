import { MapSchema,Schema, Context, type } from "@colyseus/schema";

export class Player extends Schema {
  @type("number") x: number;
  @type("number") y: number;
  inputQueue: any[] = [];
}

export class State extends Schema {
  @type({ map: Player }) players = new MapSchema<Player>();
}