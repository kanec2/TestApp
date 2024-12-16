import haxe.ui.loaders.image.HttpImageLoader;
import haxe.ui.Toolkit;
import ui.models.FriendsModelRoot;
import hx.files.File.FileWriteMode;
import hl.uv.Fs;
import hl.Api;
import hx.files.Dir;
import hx.files.Path;
import hx.concurrent.ConcurrentException;
import haxe.Exception;
import haxe.ds.Either;
import haxe.Json;
import haxe.Http;
import hx.concurrent.event.AsyncEventDispatcher;
import http.HttpResponse;
import promises.Promise;
import http.HttpError;
import queues.QueueFactory;
import http.HttpClient;
import haxe.ui.util.Variant;
import haxe.ui.assets.ImageInfo;
import haxe.ui.loaders.image.ImageLoader;
import hx.concurrent.executor.Executor;
import sys.thread.Thread;
import ui.models.FriendModel;
import hx.concurrent.collection.SynchronizedArray;
import haxe.ui.util.GUID;
import ui.views.MainView;
import ui.views.MenuVIew;
import haxe.ui.HaxeUIApp;
import systems.Render3D;
import ecs.Workflow;
import components.ResourceComponent;
import components.*;
import ecs.Entity;

typedef AppEventBase = {
    event:String, 
    data:Dynamic
}

class Main{
    static var friends:SynchronizedArray<FriendModel>;
    var menuView:MenuView;
    //var getFriendsExecutor:Executor;
    //var usersGetUrl = "http://localhost:5017/arnest/api/get-running-machine-checks-devices";
    var usersGetUrl = "http://jsonplaceholder.typicode.com/users";
    var appInitEvent:AppEventBase;
    var friendsLoadedEvent:AppEventBase;
    var executor:Executor;
    var appInited:Bool = false;
    var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    var cacheFolder:Dir;
    var appFolder:Dir;
    public function new() {

        friends = new SynchronizedArray<FriendModel>();
        executor = Executor.create(5);
        asyncDispatcher = new AsyncEventDispatcher<AppEventBase>(executor);
        asyncDispatcher.subscribe(onFriendsLoaded);
        asyncDispatcher.subscribe(onAppInited);

        checkFiles();
        fetchData();
        //initApp();
        //fetchLocalStorage();
        /*
        
        
        fetchData();
        initECS();
        */
        
    }

    function checkFiles(){
        var applicationDirectory = Sys.programPath();
        
        var appPath = Path.of(applicationDirectory);
        appFolder = appPath.parent.toDir();

        var cachePath = appPath.parent.join("cache");
        if(!cachePath.exists()) cachePath.toDir().create();
        cacheFolder = cachePath.toDir();

        var friendCache = cachePath.join("friends.json");
        if (!friendCache.exists()) friendCache.toFile().touch();
    }

    function onFriendsLoaded(event:AppEventBase){
        if(event.event != "FriendsLoaded") return;
        if(!appInited) return;
        menuView.setFriends(friends);
    }

    function onAppInited(event:AppEventBase){
        if(event.event != "AppInited") return;
        appInited = true;
        if(friends != null) menuView.setFriends(friends);
    }

    function initApp(){
        var app = new HaxeUIApp();

        app.ready(function() {
            menuView = new MenuView();
            menuView.init(getFriendList);//,getFriendList);
            HaxeUIApp.instance.icon = "assets/images/favicon.png";
            HaxeUIApp.instance.title = "GoodGames | Community and Store HTML Game Template";
            app.addComponent(menuView);
            var ev:AppEventBase = {
                event: "AppInited",
                data: null
            }
            asyncDispatcher.fire(ev);
            app.start();
        });
    }

    function initECS(){
        trace("Start ecs things");
        Workflow.addSystem(new Render3D());
        Workflow.addSystem(new systems.UISystem());
        Workflow.addSystem(new systems.ResourceProduce());
        var player:Entity = new Entity();
        var friend:FriendModel = new FriendModel();
        friends.addIfAbsent(friend);
        var resources:List<ResourceComponent> = new List<ResourceComponent>();
        resources.add(new ResourceComponent("GOLD",100));
        resources.add(new ResourceComponent("WOOD",100));
        resources.add(new ResourceComponent("STONE",100));
        player.add(new PlayerComponent(player,resources));
        trace("End ecs things");
    }

    function fetchData(){
        var apiCallTask = () -> {
            trace("Start api call");
            var result = Http.requestUrl(usersGetUrl);
            trace(result);
            return result;
        }
        var storageCallTask = () ->{
            trace("Start local read");
            var friendCache = cacheFolder.path.join("friends.json").toFile();
            var inputStream = friendCache.openInput(true);
    
            var rawData = inputStream.readAll();
            var rawJson = rawData.toString();
            trace(rawJson);
            var json:api.models.JsonModels.RootFriendsData = Json.parse(rawJson);
            return json;
        }
        trace("Submit storage call task");
        var storageCallPromise = executor.submit(storageCallTask);
        trace("Submit api call task");
        var apiCallPromise = executor.submit(apiCallTask);
        trace("Set storage completion");
        storageCallPromise.onCompletion(result->{
            trace("start read local");
            var result:api.models.JsonModels.RootFriendsData = switch (result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            };
            if(result != null && result.friends != null)
                for (rawFriend in result.friends) {
                    friends.add(new FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
                }
            var ev:AppEventBase = {
                event: "FriendsLoaded",
                data: null
            };
            asyncDispatcher.fire(ev);
        });
        
        var transformJsonToFriendsTask = function ():Bool {
            apiCallPromise.awaitCompletion(-1);
            storageCallPromise.awaitCompletion(-1);
            trace("start transform");

            var apiResult:Dynamic = switch (apiCallPromise.result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            }
            if(apiResult == null) trace("No api data");//return false;
            
            var storageResult:Dynamic = switch (storageCallPromise.result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            }
            if(storageResult == null) trace("No storage data");//return false;
            
            var mockFriendsJson:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends();

            //friendCache.openOutput(FileWriteMode.APPEND)
            
            for (rawFriend in mockFriendsJson.friends) {
                var isFriendAlreadyExist = false;
                var i = 0;
                for (friend in friends) {
                    i++;
                    if(friend.id != rawFriend.id) continue;
                    isFriendAlreadyExist = true;
                    break;
                }
                if(!isFriendAlreadyExist){
                    friends.add(new FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
                }
            }
            var ev:AppEventBase = {
                event: "FriendsLoaded",
                data: null
            };
            asyncDispatcher.fire(ev);
            return true;
        };
        trace("Submit transform task");
        var transformJsonPromise = executor.submit(transformJsonToFriendsTask);
        trace("Set transform completion");
        transformJsonPromise.onCompletion(_->{
            trace("start loading images");
            
            for(friend in friends){
                var url = "";
                if(friend.profileImageLocalUrl != null && friend.profileImageLocalUrl != "") url = friend.profileImageLocalUrl;
                else if (friend.profileImageUrl != null && friend.profileImageUrl != "") url = friend.profileImageUrl;
                else continue;
                trace("selected url: "+url);
                var task = createLoadImageTask(url);
                var future = executor.submit(task);
                var idx = friends.indexOf(friend);
                future.onCompletion(result->{
                    switch(result) {
                        case VALUE(value, time, _): {
                            trace(value.toImageData());
                            trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
                            friends[idx].image = value.toImageData();
                            menuView.setFriends(friends);
                        }
                        case FAILURE(ex, time, _):  trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
                        case PENDING(_):      trace("Nothing is happening");
                        
                    }
                });
            }
            var friendModelRoot = new FriendsModelRoot();
            friendModelRoot.fromSyncArray(friends);
            var friendCache = cacheFolder.path.join("friends.json").toFile();
            var writer = new json2object.JsonWriter<FriendsModelRoot>();
            var friendsArrayJson = writer.write(friendModelRoot);
            friendCache.writeString(friendsArrayJson);

            //var output = friendCache.openOutput(FileWriteMode.REPLACE);
            //output.writeBytes(friendsArrayJson)
            
        });
        transformJsonPromise.awaitCompletion(-1);
        
    }

    function gg():Void {
        var unused:hx.concurrent.Future.FutureCompletionListener<Void> = null;
        /*
        for(friend in newfriends){
           //Sys.sleep(2);
           friends.add(friend);
           var idx = friends.indexOf(friend);
           trace("done");
           
           menuView.setFriends(friends);
           
           
        };*/
        
    }


    function createLoadImageTask(url:String):Void->Variant{
        return ()->{
            trace("Well im here");
            var imgData:Variant = null;
            var compl:Bool = false;
            var httpImgLoader:HttpImageLoader = new HttpImageLoader();
            trace("so what");
            httpImgLoader.load(url,(inf:ImageInfo)->{
                trace("and here");
                if(inf != null && inf.data != null) { trace(inf.data); imgData = inf.data;}
                trace("agagaga: "+imgData);
                compl = true;
                //return imgData;
            });
            while(!compl) Sys.sleep(0.1);
            return imgData;
        }; 
    }

    function createLoadImageTasks(urls:Array<String>):Array<Void->Variant>{
        var tasks:Array<Void->Variant> = new Array<Void->Variant>();
        for(url in urls){
            var task:Void->Variant = ()->{
                var imgData:Variant = null;
                var compl:Bool = false;
                ImageLoader.instance.load(url,(inf:ImageInfo)->{
                    if(inf != null && inf.data != null) { trace(inf.data); imgData = inf.data;}
                    trace("agagaga: "+imgData);
                    compl = true;
                });
                while(!compl) Sys.sleep(0.1);
                return imgData;
            };
            tasks.push(task);
        }
        return tasks;
    }
    function loadUsers():Promise<HttpResponse>{
        var client = new HttpClient();
        client.followRedirects = false; // defaults to true
        //client.retryCount = 0; // defaults to 0
        //client.retryDelayMs = 1000; // defaults to 1000
       // client.provider = new MySuperHttpProvider(); // defaults to "DefaultHttpProvider"
        client.requestQueue = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE); // defaults to "NonQueue"
        //client.defaultRequestHeaders = ["someheader" => "somevalue"];
        //client.requestTransformers = [new MyRequestTransformerA(), new MyRequestTransformerB()];
        //client.responseTransformers = [new MyResponseTransformerA(), new MyResponseTransformerB()];
        var promise = client.get(usersGetUrl,null,["Content-Type"=>"Application/json"]);/*.then(response -> {
            var foo = response.bodyAsJson;
            trace(foo);
        }, (error:HttpError) -> {
            // error
            trace(error);
        });*/
        return promise;
        /*Sys.sleep(4);
        var newfriends = new Array<FriendModel>();
        newfriends.push(new FriendModel("qwe","https://placehold.co/32x32/orange/white/png","1"));
        newfriends.push(new FriendModel("bvc","adq","2"));
        newfriends.push(new FriendModel("zxc","https://placehold.co/32x32/orange/green/png","3"));
        return newfriends;*/
    }

    /*
    function getFriendList(userId:String){
        var unused:hx.concurrent.Future.FutureCompletionListener<Void> = null;
        

        var client = new HttpClient();
        client.followRedirects = false;
        client.requestQueue = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE);
        var promise = client.get(usersGetUrl,null,["Content-Type"=>"Application/json"]);

        promise.then(promiseResult->{
            var foo = promiseResult.bodyAsJson;
            getFriendsExecutor = Executor.create(3,true);  // <- 3 means to use a thread pool of 3 threads on platforms that support threads
            var syncResult = new Array<FriendModel>();
            syncResult.push(new FriendModel("qwe","https://placehold.co/32x32/orange/white/png","1"));
            syncResult.push(new FriendModel("bvc","adq","2"));
            syncResult.push(new FriendModel("zxc","https://placehold.co/32x32/orange/green/png","3"));
            var users:SynchronizedArray<FriendModel> = new SynchronizedArray<FriendModel>();
            for(user in syncResult){
                users.add(user);
            }

            for(user in users){
                //friendMap.set(user.id,user.profileImageUrl);
                var task = createLoadImageTask(user.profileImageUrl);
                var future = getFriendsExecutor.submit(task);
                var idx = users.indexOf(user);
                future.onCompletion(result->{
                    switch(result) {
                        case VALUE(value, time, _): {
                            trace(value.toImageData());
                            trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
                            users[idx].image = value.toImageData();
                            menuView.setFriends(users);
                        }
                        case FAILURE(ex, time, _):  trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
                        case PENDING(_):      trace("Nothing is happening");
                    }
                });
            }
            menuView.setFriends(users);
        });
    }*/
    function getFriendList(userId:String) {
        
    }


    public static function main(){
        new Main();
    }

}