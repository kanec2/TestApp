import services.AppEventService;
import hx.injection.ServiceCollection;
import services.GameObjectManagerService;
import hx.concurrent.collection.SynchronizedMap;
import haxe.ui.components.Image;
import hx.files.File;
import haxe.io.BytesData;
import haxe.io.Bytes;
import haxe.ui.loaders.image.HttpImageLoader;
import haxe.ui.loaders.image.FileImageLoader;
import haxe.ui.Toolkit;
import haxe.ui.backend.BackendImpl;
import ui.models.FriendsModelRoot;
import hx.files.File.FileWriteMode;
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
import hxd.BitmapData;
using hx.injection.ServiceExtensions;
typedef AppEventBase = {
    event:String, 
    data:Dynamic
}
//https://gigglingcorpse.com/2021/11/22/hello-world-heaps-on-android/
class Main{
    static var friends:SynchronizedArray<FriendModel>;
    //var menuView:MenuView;
    var menuView:HeapsMain;
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

    var imageCacheMapping:SynchronizedMap<String,String>;
    var imageCachePath:Path;
    var imageMappingFile:File;
    
    var collection:ServiceCollection;


    public function new() {
        initServices();
        var provider = collection.createProvider();
        var appEventService = provider.getService(AppEventService);
        var heapsmain = provider.getService(HeapsMain);
        
        Toolkit.onAfterInit = startup;
        friends = new SynchronizedArray<FriendModel>();
        executor = Executor.create(5);
        asyncDispatcher = appEventService.asyncDispatcher;//new AsyncEventDispatcher<AppEventBase>(executor);
        asyncDispatcher.subscribe(onFriendsLoaded);
        asyncDispatcher.subscribe(onAppInited);
        //menuView = new HeapsMain();//asyncDispatcher);
        //heapsmain.makeInit();
        
        /*
        initECS();
        */
        
    }

    function initServices(){
        collection = new ServiceCollection();
        //collection.addService(GameObjectManagerService);
        collection.addSingleton(GameObjectManagerService);
        collection.addSingleton(AppEventService);
        collection.addSingleton(HeapsMain);
    }

    function startup(){
        //trace("Im here");
        checkFiles();
        fetchData();
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

        var imageMappingPath = cachePath.join("image_mapping.json");
        if (!imageMappingPath.exists()) imageMappingPath.toFile().touch();

        imageMappingFile = imageMappingPath.toFile();
        imageCachePath = cachePath.join("images");
        if (!imageCachePath.exists()) imageCachePath.toDir().create();
        

    }

    function onFriendsLoaded(event:AppEventBase){
        if(event.event != "FriendsLoaded") return;
        if(!appInited) return;
        menuView.setFriends(friends);
    }

    function onAppInited(event:AppEventBase){
        if(event.event != "AppInited") return;
        //trace("App inited");
        appInited = true;
        if(friends != null) menuView.setFriends(friends);
    }

    function initECS(){
        //trace("Start ecs things");
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
        //trace("End ecs things");
    }

    function fetchData(){
        var apiCallTask = () -> {
            //trace("Start api call");
            var result = Http.requestUrl(usersGetUrl);
            //trace(result);
            return result;
        }
        var storageCallTask = () ->{
            //trace("Start local read");
            var friendCache = cacheFolder.path.join("friends.json").toFile();
            var inputStream = friendCache.openInput(true);
    
            var rawData = inputStream.readAll();
            var rawJson = rawData.toString();
            //trace(rawJson);
            var json:api.models.JsonModels.RootFriendsData = Json.parse(rawJson);

            var mappingStream = imageMappingFile.openInput(true);
            var rawMappingData = mappingStream.readAll();
            var rawMappingJson = rawMappingData.toString();

            var parser = new json2object.JsonParser<Map<String,String>>();
            parser.fromJson(rawMappingJson,"err");

            imageCacheMapping = SynchronizedMap.from(parser.value);
           
            return json;
        }
        //trace("Submit storage call task");
        var storageCallPromise = executor.submit(storageCallTask);
        //trace("Submit api call task");
        var apiCallPromise = executor.submit(apiCallTask);
        //trace("Set storage completion");
        storageCallPromise.onCompletion(result->{
            //trace("start read local");
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
            //trace("start transform");

            var apiResult:Dynamic = switch (apiCallPromise.result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            }
            if(apiResult == null){} //trace("No api data");//return false;
            
            var storageResult:Dynamic = switch (storageCallPromise.result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            }
            if(storageResult == null){} //trace("No storage data");//return false;
            
            var mockFriendsJson:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends();

            //friendCache.openOutput(FileWriteMode.APPEND)
            
            for (rawFriend in mockFriendsJson.friends) {
                var isFriendAlreadyExist = false;
                for (friend in friends) {
                    if(friend.id != rawFriend.id) continue;
                    isFriendAlreadyExist = true;
                    break;
                }
                if(!isFriendAlreadyExist){
                    friends.add(new FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
                }
            }
            var i = 0;
            for (friend in friends){
                var key = friend.id;
                if(imageCacheMapping.exists(key)){
                    var fullPath = imageCachePath.join(imageCacheMapping.get(key)).getAbsolutePath();
                    friends[i].profileImageLocalUrl = fullPath;
                }
                i++;
            }
            var ev:AppEventBase = {
                event: "FriendsLoaded",
                data: null
            };
            asyncDispatcher.fire(ev);
            return true;
        };
        //trace("Submit transform task");
        var transformJsonPromise = executor.submit(transformJsonToFriendsTask);

        var loadImagesTask = function ():Array<TaskFuture<Void>>{
            transformJsonPromise.awaitCompletion(-1);
            //trace("start loading images");
            var promises:Array<TaskFuture<Void>> = new Array<TaskFuture<Void>>();
            for(friend in friends){
                var url = "";

                //trace("r url: "+friend.profileImageLocalUrl);
                if(friend.profileImageLocalUrl != null && friend.profileImageLocalUrl != "") url = friend.profileImageLocalUrl;
                else if (friend.profileImageUrl != null && friend.profileImageUrl != "") url = friend.profileImageUrl;
                else continue;
                //trace("selected url: "+url);
                var idx = friends.indexOf(friend);
                var task = createLoadImageTask(idx,url);
                var future = executor.submit(task);
                promises.push(future);
            }
            return promises;
        }
        var loadImagesPromise = executor.submit(loadImagesTask);

        var saveImagesTask = function():Void{
            loadImagesPromise.awaitCompletion(-1);
            var promises:Array<TaskFuture<Void>> = switch (loadImagesPromise.result){
                case VALUE(value, time, _): value;
                case FAILURE(ex, time, _): null;
                case PENDING(_): null;
                default: null;
            }
            for(p in promises) p.awaitCompletion(-1);
            for(friend in friends){
                var img = friend.image;
                if(img == null) continue;
                var imgData = img.toImageData();

                var imgCacheName = friend.id + "_profile";
                if(imageCacheMapping.exists(imgCacheName)) continue;

                var cacheFile = imageCachePath.join(imgCacheName + ".png");
                
                var imageBytes = imgData.toPNG();
                //cacheFile.toFile().touch();
                try{
                    cacheFile.toFile().writeBytes(imageBytes,false);
                }
                catch(e){}
                imageCacheMapping.set(friend.id,imgCacheName + ".png");
                friend.profileImageLocalUrl = imgCacheName + ".png";
                //trace("image saved");
                ////trace("result bytes: ");
                ////trace(bb);
                //stream.write();
                //cacheFile.writeBytes(img.toImageData());
            }
            //trace("I waited for eternity");
            var friendModelRoot = new FriendsModelRoot();
            friendModelRoot.fromSyncArray(friends);
            var friendCache = cacheFolder.path.join("friends.json").toFile();
            var writer = new json2object.JsonWriter<FriendsModelRoot>();
            var friendsArrayJson = writer.write(friendModelRoot);
            friendCache.writeString(friendsArrayJson);

            var imageWriter = new json2object.JsonWriter<Map<String,String>>();
            var syncMapping:Map<String,String> = new Map<String,String>();
            for(key in imageCacheMapping.keys()){
                var value = imageCacheMapping.get(key);
                syncMapping.set(key,value);
            }
            var imageJson = imageWriter.write(syncMapping);
            imageMappingFile.writeString(imageJson);
            //var output = friendCache.openOutput(FileWriteMode.REPLACE);
            //output.writeBytes(friendsArrayJson)
            
        };
        executor.submit(saveImagesTask);
        //transformJsonPromise.awaitCompletion(-1);
        
    }

    function gg():Void {
        var unused:hx.concurrent.Future.FutureCompletionListener<Void> = null;
        /*
        for(friend in newfriends){
           //Sys.sleep(2);
           friends.add(friend);
           var idx = friends.indexOf(friend);
           //trace("done");
           
           menuView.setFriends(friends);
           
           
        };*/
        
    }
/*
    function decodePNG(src:haxe.io.Bytes, width:Int, height:Int, requestedFmt:hxd.PixelFormat) {
		var outFmt = requestedFmt;
        var gg:format.hl.Reader = new format.hl.Reader();
        var dt:format.hl.Data = gg.read();
        
		var ifmt:format.hl.Native. = switch (requestedFmt) {
			case RGBA: RGBA;
			case BGRA: BGRA;
			case ARGB: ARGB;
			case R16U: cast 12;
			case RGB16U: cast 13;
			case RGBA16U: cast 14;
			case RG16U: cast 15;
			default:
				outFmt = BGRA;
				BGRA;
		};
		var stride = 4; // row_stride is the step, in png_byte or png_uint_16 units	as appropriate, between adjacent rows
		var pxsize = 4;
		switch (outFmt) {
			case R16U:
				stride = 1;
				pxsize = 2;
			case RG16U:
				stride = 2;
				pxsize = 4;
			case RGB16U:
				stride = 3;
				pxsize = 6;
			case RGBA16U:
				stride = 4;
				pxsize = 8;
			default:
		}
		var dst = haxe.io.Bytes.alloc(width * height * pxsize);
		if (!format.hl.Native.decodePNG(src.getData(), src.length, dst.getData(), width, height, width * stride, ifmt, 0))
			return null;
		var pix = new hxd.Pixels(width, height, dst, outFmt);
		return pix;
	}*/

    function createLoadImageTask(idx:Int,url:String):Void->Void{
        return ()->{
            //trace("Well im here");
            if(url.indexOf("http") > -1){
                var httpImgLoader:ImageLoader = ImageLoader.instance;
                //trace("so what htt");
                httpImgLoader.load(url,(inf:ImageInfo)->{
                    if(inf != null && inf.data != null) { 
                        //trace(inf.data); 
                        friends[idx].image = inf.data;
                        //trace(menuView);
                        menuView.setFriends(friends);
                        //trace("and here");
                    }
                });
            }
            else{
                //var imgFile = File.of(url);
                //var bytes = imgFile.readAsBytes();
                //var hlBytes = hl.Bytes.fromBytes(bytes);
                /*var innerBitmap:{
                    pixels:hl.Bytes,
                    width:Int,
                    height:Int,
                } = ;
                var bitmapData = BitmapData.fromNative(innerBitmap);
                friends[idx] = bitmapData;
                menuView.setFriends(friends);*/
                //var bitmapData:DitmapData = new BitmapData(32,32);

                //var i = sys.io.File.read(url,true);
                var imgFile = File.of(url);
                var input = imgFile.openInput(true);
                var data = new format.png.Reader(input).read();
                var bytes = format.png.Tools.extract32(data);
                var header = format.png.Tools.getHeader(data);
                input.close();
                //var imgFile = File.of(url);
                //var bytes = imgFile.readAsBytes();
                //var pixels = decodePNG(bytes, 32, 32, null);
				//if (pixels == null)
				//	throw "Failed to decode PNG";
                //hl.Bytes.fromBytes
                var hlBytes = hl.Bytes.fromBytes(bytes);
                var innerBitmap:BitmapInnerData = new BitmapInnerData();
                innerBitmap.height = header.height;
                innerBitmap.width = header.width;
                innerBitmap.pixels = hlBytes;
                var bitmapData:BitmapData = BitmapData.fromNative(innerBitmap);
                //trace(bitmapData);
                //var bitmap:ImageInfo = new ImageInfo(32,null,32,bitmapData);
                friends[idx].image = bitmapData;
                menuView.setFriends(friends);
                /*
                var httpImgLoader:ImageLoader = ImageLoader.instance;
                //trace("so what fil");
                httpImgLoader.load(url,(inf:ImageInfo)->{
                    if(inf != null && inf.data != null) { 
                        //trace(inf.data); 
                        friends[idx].image = inf.data;
                        //trace(menuView);
                        menuView.setFriends(friends);
                        //trace("and here");
                    }
                });*/
                
            }
        }
    }
    /*
    function createLoadImageTasks(urls:Array<String>):Array<Void->Variant>{
        var tasks:Array<Void->Variant> = new Array<Void->Variant>();
        for(url in urls){
            var task:Void->Variant = ()->{
                var imgData:Variant = null;
                var compl:Bool = false;
                ImageLoader.instance.load(url,(inf:ImageInfo)->{
                    if(inf != null && inf.data != null) { //trace(inf.data); imgData = inf.data;}
                    //trace("agagaga: "+imgData);
                    compl = true;
                });
                while(!compl) Sys.sleep(0.1);
                return imgData;
            };
            tasks.push(task);
        }
        return tasks;
    }*/
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
            //trace(foo);
        }, (error:HttpError) -> {
            // error
            //trace(error);
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
                            //trace(value.toImageData());
                            //trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
                            users[idx].image = value.toImageData();
                            menuView.setFriends(users);
                        }
                        case FAILURE(ex, time, _):  //trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
                        case PENDING(_):      //trace("Nothing is happening");
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
typedef TeamLobbyData = {
    teams:Array<{teamName:String, teamColor:String, teamPlayers:Array<{userName:String, firstName:String, lastName:String, active:Bool, lobbySpot:Int}> }>,
    rules:String,
    hostId:String,
    lobbyCapacity:Int,
    gameMode:String,
    numTeams:Int,
    lobbyId:String
}