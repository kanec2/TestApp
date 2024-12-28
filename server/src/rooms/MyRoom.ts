import { Room, Client, updateLobby } from "@colyseus/core";
import { State, Player } from "./schema/State";
import { Schema, type, MapSchema, ArraySchema } from "@colyseus/schema";

/*
class Container extends Schema {
  @type({ map: "string" }) testMap = new MapSchema<string>();
  @type(["number"]) testArray = new ArraySchema<number>();
}

class State extends Schema {
  @type(Container) container = new Container();
}*/

export class MyRoom extends Room<State> {
  maxClients = 4;

  update(deltaTime: number) {
    const velocity = 2;

    this.state.players.forEach(player => {
        let input: any;

        // dequeue player inputs
        while (input = player.inputQueue.shift()) {
            if (input.left) {
                player.x -= velocity;

            } else if (input.right) {
                player.x += velocity;
            }

            if (input.up) {
                player.y -= velocity;

            } else if (input.down) {
                player.y += velocity;
            }
        }
    });
}
  onCreate (options: any) {
    this.setState(new State());
    //
    // This is just a demonstration
    // on how to call `updateLobby` from your Room
    //
    this.clock.setTimeout(() => {

      this.setMetadata({
        customData: "Hello world!"
      }).then(() => updateLobby(this));

    }, 5000);
    this.setSimulationInterval((deltaTime) => {
      this.update(deltaTime);
    });
    // handle player input
    this.onMessage(0, (client, payload) => {
      // get reference to the player who sent the message
      const player = this.state.players.get(client.sessionId);

      // enqueue input to user input buffer.
      player.inputQueue.push(payload);
    });
    this.onMessage("type", (client, message) => {
      //
      // handle "type" message
      //
    });
  }

  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");

        const mapWidth = 800;
        const mapHeight = 600;

        // create Player instance
        const player = new Player();

        // place Player at a random position
        player.x = (Math.random() * mapWidth);
        player.y = (Math.random() * mapHeight);

        // place player in the map of players by its sessionId
        // (client.sessionId is unique per connection!)
        this.state.players.set(client.sessionId, player);
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }



}
