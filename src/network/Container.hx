package network;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Container extends Schema {
	@:type("map", "string")
	public var testMap: MapSchema<String> = new MapSchema<String>();

	@:type("array", "number")
	public var testArray: ArraySchema<Dynamic> = new ArraySchema<Dynamic>();

}