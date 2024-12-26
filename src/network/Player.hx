package network;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Player extends Schema {
	@:type("number")
	public var x: Float;

	@:type("number")
	public var y: Float;

}