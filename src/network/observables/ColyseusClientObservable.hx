package network.observables;

import io.colyseus.Client;
import io.colyseus.Room;
import promises.Promise;

using libs.rx.Observable;

class ColyseusClientObservable<TState, TMessage> {
    public var serverUrl:String;
    public var client:Client;

    public function new(serverUrl:String) {
        this.serverUrl = serverUrl;
        this.client = new Client(serverUrl);
    }

    /**
     * Joins a room and returns a Promise with ColyseusRoomObservable.
     */
    public function joinRoom(roomName:String, options:Dynamic = null):Promise<ColyseusRoomObservable<TState, TMessage>> {
        return new Promise((resolve, reject) -> {
            client.join(roomName,options,TState, (error, room) -> {
                if (err != null) {
                    reject(err.message);
                }
                var roomObservable = new ColyseusRoomObservable<TState, TMessage>(room);
                resolve(roomObservable);
            });
        });

        
        /*
        return client.join<TState>(roomName, options).map(room -> {
            return new ColyseusRoomObservable<TState, TMessage>(room);
        });*/

    }
}