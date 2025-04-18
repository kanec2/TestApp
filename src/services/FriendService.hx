package services;

import http.HttpClient;
import http.HttpError;
import hx.injection.config.Configuration;
import hx.files.File.FileWriteMode;
import hx.files.Dir;
import hx.files.Path;
import haxe.Json;
import libs.rx.Subscription;
using libs.rx.Observable;

class FriendService extends IFriendService
{
    var _config : Config;
    public function new(configuration : Config){
        this._config = configuration;
    }
    public function getFriends():Observable<Array<api.models.JsonModels.FriendsData>>
    {
        return getFriendsFromApi().combineLatest([getFriendsFromStorage()], (arr: Array<api.models.JsonModels.FriendsData>) ->{
            return arr[0];
        } );
    }
    public function getFriendsFromApi():Observable<Array<api.models.JsonModels.FriendsData>>
    {
        
        //var _config = configuration;//.getConfig();
        //trace(_config);
        var apiFriendsCall = Observable.create(_observer -> {
            var client = new HttpClient();
            client.followRedirects = false; // defaults to true
            client.retryCount = 5; // defaults to 0
            client.retryDelayMs = 0; // defaults to 1000
            client.get(_config.usersGetUrl, [], []).then(response -> {
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                // error
                _observer.on_error(error.bodyAsString);
            });
            return Subscription.empty();
        }).map((rawJson)->{
            var json:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends();
            //var json:api.models.JsonModels.RootFriendsData = Json.parse(rawJson)
            var arrFriend = [];
            for (rawFriend in json.friends) {
                arrFriend.push(rawFriend);//new ui.models.FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
            }
            return arrFriend;
        });
        return apiFriendsCall;
    }
    public function getFriendsFromStorage():Observable<Array<api.models.JsonModels.FriendsData>>
    {
        var storageApiCall = Observable.create(_observer->{
            var applicationDirectory = Sys.programPath();
        
            var appPath = Path.of(applicationDirectory);
            var appFolder = appPath.parent.toDir();

            var cachePath = appPath.parent.join(_config.cachePath);
            if(!cachePath.exists()) cachePath.toDir().create();
            var cacheFolder = cachePath.toDir();

            var friendCache = cacheFolder.path.join(_config.friendCache).toFile();
            var inputStream = friendCache.openInput(true);
    
            var rawData = inputStream.readAll();
            var rawJson = rawData.toString();
            _observer.on_next(rawJson);
            _observer.on_completed();
            return Subscription.empty();
        }).map((rawJson) ->{
            //var json:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends();
            var json:api.models.JsonModels.RootFriendsData = Json.parse(rawJson);
            var arrFriend = [];
            trace(rawJson);
            for (rawFriend in json.friends) {
                arrFriend.push(rawFriend);//new ui.models.FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
            }
            return arrFriend;
        });
        return storageApiCall;
    }
}