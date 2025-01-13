package model;

import io.colyseus.Room;
import io.colyseus.Client;

class AppData {
    public var client: Client;
    public var currentRoom:Room<Dynamic>;

    public function new(endpoint:String) {
        this.client = new Client(endpoint);
    }
}