
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
                    "id": "C1ACDCCE-5662-44AF-B279-9DC5186B772D",
                    "nickName": "Nagib17",
                    "profileImageUrl": null,
                    "profileImageLocalUrl": null
                }
            ]
        }');
        return json;
    }
}