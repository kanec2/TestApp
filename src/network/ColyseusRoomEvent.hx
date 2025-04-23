package network;

typedef ColyseusRoomEvent<TState, TMessage> = {
    eventType: ColyseusRoomEventType;
    state: Null<TState>;
    message: Null<TMessage>;
    leaveCode: Null<Int>;
    leaveReason: Null<String>;
    error: Null<String>;
}