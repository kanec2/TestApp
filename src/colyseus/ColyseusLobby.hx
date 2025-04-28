package colyseus;

import io.colyseus.Room;
import io.colyseus.Client;

class ColyseusLobby
{
    private var _clinet:Client;

    public var room:Room<Dynamic>;

    public var onRooms:Dynamic->Void;

    public var onAddRoom:String->Dynamic->Void;// Action<string, ColyseusRoomAvailable> OnAddRoom;

    public var onRemoveRoom:String->Void;

    public function new(client:Client)
    {
        _client = client;
    }
    public function connect(){
        var cl:Client;
        var r:Room<Dynamic>;
        r.onMessage(typeof(Dynamic),onRoomsMessage);

        cl.joinOrCreate("lobby",[],Dynamic,(error,lobbyRoom)->{
            room = lobbyRoom;
            room.onMessage(typeof(Dynamic),onRoomsMessage);
        })
    }

    function onRoomsMessage(rooms:Dynamic){
        onRooms(rooms);
    }
    public async Task Connect()
    {
        room = await _client.JoinOrCreate("lobby");

        room.OnMessage<ColyseusRoomAvailable[]>("rooms", OnRoomsMessage);
        room.OnMessage<object[]>("+", OnAddRoomMessage);
        room.OnMessage<string>("-", OnRemoveRoomMessage);
    }


    void OnRoomsMessage(ColyseusRoomAvailable[] rooms)
    {
        OnRooms?.Invoke(rooms);
    }

    private T ConvertData<T>(ref T obj, FieldInfo[] fields, IndexedDictionary<string, object> data)
    {
        foreach (FieldInfo field in fields)
        {
            if (data.ContainsKey(field.Name))
            {
                data.TryGetValue(field.Name, out object value);

                if (value is IndexedDictionary<string, object> indexedDictionary)
                {
                    object fieldValue = Activator.CreateInstance(field.FieldType);
                    field.SetValue(obj, ConvertData(ref fieldValue, field.FieldType.GetFields(), indexedDictionary));
                }
                else if (field.FieldType == value.GetType())
                {
                    field.SetValue(obj, value);
                }
            }
        }

        return obj;
    }

    void OnAddRoomMessage(object[] info)
    {
        var roomId = (string)info[0];
        var data = (IndexedDictionary<string, object>)info[1];

        var roomInfo = new ColyseusRoomAvailable();
        var roomType = typeof(ColyseusRoomAvailable);

        FieldInfo[] fields = roomType.GetFields();

        ConvertData(ref roomInfo, fields, data);

        OnAddRoom?.Invoke(roomId, roomInfo);

    }

    void OnRemoveRoomMessage(string roomId)
    {
        OnRemoveRoom?.Invoke(roomId);
    }
}