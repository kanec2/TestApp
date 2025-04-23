package network.observables;

import io.colyseus.Room;

using libs.rx.Observable;

class ColyseusRoomObservable <TState, TMessage>
{
    private var _room: Room<TState>;
    private var _subject:Subject<ColyseusRoomEvent<TState, TMessage>>;

    public function new(room:Room<TState>)
    {
        _room = room;
        _subject = new Subject<ColyseusRoomEvent<TState, TMessage>>();

        setupRoomEventHandlers();
    }

    private function setupRoomEventHandlers():Void {
        room.onJoin = () -> {
            subject.onNext({
                eventType: ColyseusRoomEventType.Join,
                state: null,
                message: null,
                leaveCode: null,
                leaveReason: null,
                error: null
            });
        };

        room.onLeave = (code:Int, reason:String) -> {
            subject.onNext({
                eventType: ColyseusRoomEventType.Leave,
                state: null,
                message: null,
                leaveCode: code,
                leaveReason: reason,
                error: null
            });
            subject.onCompleted();
        };

        room.onError = (message:String) -> {
            subject.onNext({
                eventType: ColyseusRoomEventType.Error,
                state: null,
                message: null,
                leaveCode: null,
                leaveReason: null,
                error: message
            });
            subject.onError(message);
        };

        room.onStateChange = (state:TState) -> {
            subject.onNext({
                eventType: ColyseusRoomEventType.StateChange,
                state: state,
                message: null,
                leaveCode: null,
                leaveReason: null,
                error: null
            });
        };

        room.onMessage = (msg:Dynamic) -> {
            var typedMsg:TMessage;
            try {
                typedMsg = cast(msg);
                subject.onNext({
                    eventType: ColyseusRoomEventType.Message,
                    state: null,
                    message: typedMsg,
                    leaveCode: null,
                    leaveReason: null,
                    error: null
                });
            } catch(e:Dynamic) {
                subject.onError("Message cast error: " + Std.string(e));
            }
        };
    }

    /**
     * Returns an Observable to subscribe to room events.
     */
     public function asObservable():Observable<ColyseusRoomEvent<TState, TMessage>> {
        return subject;
    }

    /**
     * Send a message to the room.
     */
     public function send(message:Dynamic):Void {
        if (room != null) {
            room.send(message);
        } else {
            throw "No room joined yet.";
        }
    }

    /**
     * Leaves the room, closes observable.
     */
     public function leave():Promise<Void> {
        if (room != null) {
            return room.leave();
        }
        return Promise.resolve(null);
    }
}