// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.36
// 
package network.states;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class State extends Schema {
	@:type("map", Player)
	public var players: MapSchema<Player> = new MapSchema<Player>();

}
