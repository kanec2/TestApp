package network;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class State extends Schema {
	@:type("map", "string")
	public var players: MapSchema<Player> = new MapSchema<Player>();

}