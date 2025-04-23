
import haxe.Json;

class Mock {

    public static function getMockJsonFriends():api.models.JsonModels.RootFriendsData {
        var json:api.models.JsonModels.RootFriendsData = Json.parse('{
            "friends":[
                {
                    "id": "1FF897E4-1564-4054-8F92-C5DF80912C23",
                    "nickName": "John",
                    "profileImageUrl": "https://placehold.co/32x32/orange/white/png",
                    "profileImageLocalUrl": ""
                },
                {
                    "id": "C1ACDCCE-5662-44AF-B279-9DC5186B772D",
                    "nickName": "Nagib17",
                    "profileImageUrl": "https://placehold.co/32x32/orange/green/png",
                    "profileImageLocalUrl": null
                },
                {
                    "id": "ZXCVDCCE-2134-44AF-B279-9DC5186B772D",
                    "nickName": "Rony",
                    "profileImageUrl": null,
                    "profileImageLocalUrl": null
                }
            ]
        }');
        return json;
    }
    public static function getMockJsonNoFriends():api.models.JsonModels.RootFriendsData {
        var json:api.models.JsonModels.RootFriendsData = Json.parse('{
            "friends":[
               
            ]
        }');
        return json;
    }
    public static function getLobbyInfo(lobbyId:String):api.models.JsonModels.LobbyData {
        var jsonString = '{
            "lobbyId": "YUFhkw3423",
            "players": [
                {"nickName":"Nagib19", "playerId":"ruewi4389rr", "selectedRace":"None", "lobbySpot":"1", "rating":"345", "rank":"Soldier", "team":"Red team"},
                {"nickName":"You", "playerId":"Qrt5E32e", "selectedRace":"Goblin/Elf", "lobbySpot":"2", "rating":"1140", "rank":"Colonel", "team":"Red team"},
                {"nickName":"Other player", "playerId":"ZXCqwe123", "selectedRace":"Human/Demon", "lobbySpot":"1", "rating":"777", "rank":"Colonel", "team":"Blue team"}
            ],
            "hostId":"ruewi4389rr",
            "rules":"Standard rules",
            "lobbyCapacity": 6,
            "gameMode":"2x2x2x2"
        }';

        var parser = new json2object.JsonParser<api.models.JsonModels.LobbyData>();
        parser.fromJson(jsonString,"err");

        
        var json:api.models.JsonModels.LobbyData = parser.value;

        return json;
    }
}