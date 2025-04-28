package services;

import libs.rx.Scheduler;
import libs.rx.observables.MakeScheduled.SubscribeOnThis;
import libs.rx.Observer;
import libs.rx.observables.ObserveOnThis;
import api.models.JsonModels.FriendsData;
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
    var _httpClient : HttpClientService;
    public function new(configuration : Config, httpClient:HttpClientService){
        this._config = configuration;
        this._httpClient = httpClient;
    }
    function mergeArrays(
        array1:Array<FriendsData>,
        array2:Array<FriendsData>
    ):Array<FriendsData> {
        var mapIdToProfile = new Map<String, FriendsData>();
    
        // Заполняем карту из первого массива
        for (p in array1) {
            mapIdToProfile.set(p.id, p);
        }
    
        // Проходим по второму массиву
        for (p in array2) {
            var existing = mapIdToProfile.get(p.id);
            if (existing != null) {
                // Обновляем profileImageLocalUrl в существующем элементе
                existing.profileImageLocalUrl = p.profileImageLocalUrl;
            } else {
                // Если элемента нет, добавляем в карту и массив
                mapIdToProfile.set(p.id, p);
                array1.push(p);
            }
        }
    
        // Возвращаем обновлённый первый массив или можно вернуть значения карты
        return array1;
    }

    public function getFriends():Observable<Array<api.models.JsonModels.FriendsData>>
    {

        return getFriendsFromApi().combineLatest([getFriendsFromStorage()], (arr: Array<Array<api.models.JsonModels.FriendsData>>) ->{
            trace("Len: "+arr.length);

            var arr1 = arr[0];
            var arr2 = arr[1];
            trace("arr1: "+arr1);
            trace("arr2: "+arr2);
            var resarr = mergeArrays(arr1,arr2);
            trace(resarr);
            return resarr;//arr1.concat(arr2);
        } );
    }
    public function getFriendsFromApi():Observable<Array<api.models.JsonModels.FriendsData>>
    {
        var apiFriendsCall = Observable.create(_observer -> {
            _httpClient.getClient().get(_config.usersGetUrl, [], []).then(response -> {
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });
            return Subscription.empty();
        })
        //.subscribeOn(backgroundExecutor) // run HTTP request subscription on background thread
        .map((rawJson)->{
            var json:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends(); // replace with JSON parse of rawJson
            var arrFriend = [];
            for (rawFriend in json.friends) {
                arrFriend.push(rawFriend);
            }
            return arrFriend;
        });
        //.observeOn(mainExecutor); // observe results on main thread executor (replace with your main/UI thread)
    
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

    function isSuccessStatusCode(statusCode:Int):Bool return statusCode >= 200 && statusCode <300;
    
    public function addFriend(username:String) : Observable<Bool>
    { 
        return Observable.create(_observer->{
            _httpClient.getClient().post(_config.addFriendsUrl, {username: username}, [], []).then(response -> {
                _observer.on_next(isSuccessStatusCode(response.httpStatus));
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });

            return Subscription.empty();
        });
    }
}