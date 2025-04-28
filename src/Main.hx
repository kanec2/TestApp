//import libs.rx.schedulers.NewThreadScheduler;
import libs.rx.ObservableFactory;
import libs.rx.observables.ObserveOn;
import libs.rx.observables.SubscribeOn;
import hx.concurrent.executor.Executor;
import libs.rx.observables.MakeScheduled;
import libs.rx.schedulers.NewThread;
import libs.rx.Scheduler;
import libs.rx.schedulers.Base;
import libs.rx.Subscription;
import libs.rx.Observer;
import libs.rx.observers.IObserver;
import libs.rx.observables.Create;
//import libs.rx.schedulers.ISchedulerBase;
import libs.rx.schedulers.IScheduler;
import libs.rx.schedulers.DiscardableAction;
import libs.rx.Utils;
import haxe.Timer;
import libs.rx.Subscription;
//import libs.rx.schedulers.NewThreadScheduler;
import libs.rx.disposables.ISubscription;
import libs.rx.subjects.Async;
import libs.rx.subjects.Replay;
import sys.thread.Thread;
import http.HttpClient;
import http.HttpError;
import hx.files.File;

import hx.files.File.FileWriteMode;
import hx.files.Dir;
import hx.files.Path;
import haxe.ds.Either;

import haxe.Http;
import hx.injection.config.Configuration;
import haxe.ui.util.Variant;

import ecs.Entity;
import haxe.Json;
import hx.injection.ServiceCollection;

import h3d.col.Bounds;
import h3d.mat.Texture;
import h3d.prim.Cube;
import ui.views.HUD;
import ui.views.BuildingMenu;

import haxe.ui.backend.BackendImpl;
import ui.models.FriendModel;
import hx.concurrent.collection.SynchronizedArray;
import haxe.ui.core.Screen;
import ui.views.MenuVIew;
import haxe.ui.Toolkit;
import io.colyseus.Client;
import hx.concurrent.collection.SynchronizedMap;
import hx.injection.config.ConfigurationBuilder;

import enums.AppEvent;
using libs.rx.Observable;
using tweenxcore.Tools;
using hx.injection.ServiceExtensions;
using Safety;

//https://gigglingcorpse.com/2021/11/22/hello-world-heaps-on-android/
class Main extends hxd.App {
   

    //var gameObjectManager : GameObjectManagerService;

    var gameObjects   : Array<GameObject> = [];
    var movingObjects : Array<MapObject>  = [];
    var objectMapping : Map<MapObject,MiniMapObject> = new Map<MapObject, MiniMapObject>();
    //var miniMapObjects : Array<{ m : h3d.scene.Mesh, cx : Float, cy : Float, pos : Float, ray : Float, speed : Float }> = [];
    var bitmap : h2d.Bitmap;
    var controller : h3d.scene.CameraController;

    var objectModels : Array<{id:String, cx:Float, cy: Float, objectType:String, relation:String}> = [];

    var buildings : Array<{id:String, cx: Float, cy: Float, pos: Float, ray:Float}> = [];

    public var menuView:MenuView;
    public var otherMenu:BuildingMenu;
    //var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    var userToken:String;

    var serviceProvider: hx.injection.ServiceProvider;
    
//    var auth = new Auth("localhost", 2567);
    var client = new Client("localhost",2567);

    var signedId:Bool = false;

    var userProfile:{
        name:String,
        rank:String,
        locale:String,
        rating:Int
    }

    // local input cache
    var inputPayload = {
        left: false,
        right: false,
        up: false,
        down: false,
    };

    /*Service List*/


    var renderTarget:Texture;
    var s3dTarget:h3d.scene.Scene;
    
    var usersGetUrl = "http://jsonplaceholder.typicode.com/users";
    var serviceCollection:ServiceCollection;
    var cacheFolder:Dir;
    public function new() {
        super();
        
    }
    static function printArray(_array:Array<Int>)
        trace(_array);


    function initServices(){

        var builder = ConfigurationBuilder.create('configs');
        var configApp:ApplicationConfig = builder.resolveJson('app-config.json');
        var config:Config = new Config();
        config.appConfig = configApp;
        serviceCollection = new ServiceCollection();
        serviceCollection.addSingleton(services.FriendService);
        serviceCollection.addConfig(config);
        trace("IS IT PROBLEM HERE?");
        /*
        var applicationDirectory = Sys.programPath();
        
        var appPath = Path.of(applicationDirectory);
        var appFolder = appPath.parent.toDir();

        var configPath = appPath.parent.join("configs");
        if(!configPath.exists()) configPath.toDir().create();
        var configFolder = configPath.toDir();

        var configFile = configFolder.path.join("app-config.json").toFile();
        var inputStream = configFile.openInput(true);

        var rawData = inputStream.readAll();
        var rawJson = rawData.toString();
        //trace("raw conf: "+ rawJson);
            //trace(rawJson);
        //var json = Json.parse(rawJson);
		//var config:ApplicationConfig = builder.resolveJson('app-config.json');
        //var config = 
        //var configuration = new Configuration(rawData);
        
        //trace("not raw conf: "+configuration.getString());
        //var config:ApplicationConfig = builder.build();
        serviceCollection = new ServiceCollection();
        //trace("AH, I SEE NOW : " + config);
        serviceCollection.addConfig(configuration);
        trace("ALL GOOD?");
        //serviceCollection.addSingleton(services.ConfigurationHolderService);
        serviceCollection.addSingleton(services.FriendService);
        */


    }

    function startup(){
        trace("Im here");
        trace("U GONNA DIE WHERE?");
        initServices();
        var provider = serviceCollection.createProvider();
        trace("U GONNA DIE HERE?");
        //var configService = provider.getService(services.ConfigurationHolderService);
        trace("Whats wrong?");
        var friendService = provider.getService(services.FriendService);

        //var provider = collection.createProvider();
        //var appEventService = provider.getService(AppEventService);
        //var heapsmain = provider.getService(HeapsMain);
        
        //Toolkit.onAfterInit = startup;
        //friends = new SynchronizedArray<FriendModel>();
        
        //var friendsObservable = Observable.
        //executor = Executor.create(5);
        //asyncDispatcher = appEventService.asyncDispatcher;//new AsyncEventDispatcher<AppEventBase>(executor);
        //appEventService.subscribe(onFriendsLoaded);
        //appEventService.subscribe(onAppInited);
        //new HeapsMain(provider);
        /*
        var apiFriendsCall = new Create(function(observer:IObserver<Dynamic>) {
            var result = Http.requestUrl(usersGetUrl);
            observer.on_next(result);
            observer.on_completed();
            return Subscription.empty();
        });*/
        // Threaded example.
		//final rep             = new Replay<Array<Int>>();
	    final threadScheduler = new NewThread(); //NewThreadScheduler();
		//final mainSheduler    = new SpecificThreadScheduler(Thread.current());
        var executor = Executor.create(10);

        var source = Observable.create(function(observer) {
            for(i in 0...5) {
                observer.on_next(i);
            }
            observer.on_completed();
            return Subscription.empty();
        });
        var friendsObservable = friendService.getFriends();

        var observable = new SubscribeOn(source, executor);
        var observable2 = new ObserveOn(observable, executor);
        ObservableFactory.observer(observable2,v -> trace("Got value: " + v));


		final threadID = Thread.current();
        threadID.setName("FIRST");
		trace('main thread is ${threadID}');
        var observ = Observer.create(()->{},(e)->{trace("Error: "+e);},(v)->{trace(v);});
        friendService.getFriends().subscribe(observ);
        var scehduled = new MakeScheduled();
        //var combinator:Array<api.models.JsonModels.RootFriendsData>->api.models.JsonModels.RootFriendsData=function(args:Array<api.models.JsonModels.RootFriendsData>){ 
        //    return args[0]+""+args[1];
        //};
       /* var apiFriendsCall = Observable.create(_observer -> {
            var client = new HttpClient();
            client.followRedirects = false; // defaults to true
            client.retryCount = 5; // defaults to 0
            client.retryDelayMs = 0; // defaults to 1000
            //client.provider = new MySuperHttpProvider(); // defaults to "DefaultHttpProvider"
            //client.requestQueue = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE); // defaults to "NonQueue"
            //client.defaultRequestHeaders = ["someheader" => "somevalue"];
            //client.requestTransformers = [new MyRequestTransformerA(), new MyRequestTransformerB()];
            //client.responseTransformers = [new MyResponseTransformerA(), new MyResponseTransformerB()];
            client.get(usersGetUrl, [], []).then(response -> {
                //var foo = response.bodyAsJson;
                //trace("Loaded data: "+foo);
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                // error
                _observer.on_error(error.bodyAsString);
            });*/
            /*
            var result = Http.requestUrl(usersGetUrl);
            var mockFriendsJson:api.models.JsonModels.RootFriendsData = Mock.getMockJsonFriends();
            _observer.on_next(mockFriendsJson);*/
            //_observer.on_completed();
            //return Subscription.empty();
        //});//.subscribe(observ);
        /*.map((v:api.models.JsonModels.RootFriendsData)->{
            var arrFriend = [];
            trace(v);
            for (rawFriend in v.friends) {
                arrFriend.push(new FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
            }
            return arrFriend;
        }).subscribe(observ);*/
        
        var storageApiCall = Observable.create(_observer->{
            var applicationDirectory = Sys.programPath();
        
            var appPath = Path.of(applicationDirectory);
            var appFolder = appPath.parent.toDir();

            var cachePath = appPath.parent.join("cache");
            if(!cachePath.exists()) cachePath.toDir().create();
            cacheFolder = cachePath.toDir();

            var friendCache = cacheFolder.path.join("friends.json").toFile();
            var inputStream = friendCache.openInput(true);
    
            var rawData = inputStream.readAll();
            var rawJson = rawData.toString();
            //trace(rawJson);
            var json:api.models.JsonModels.RootFriendsData = Json.parse(rawJson);
           
            var imageMappingPath = cachePath.join("image_mapping.json");
            if (!imageMappingPath.exists()) imageMappingPath.toFile().touch();
    
            var imageMappingFile = imageMappingPath.toFile();
            var imageCachePath = cachePath.join("images");
            if (!imageCachePath.exists()) imageCachePath.toDir().create();

            var mappingStream = imageMappingFile.openInput(true);
            var rawMappingData = mappingStream.readAll();
            var rawMappingJson = rawMappingData.toString();

            var parser = new json2object.JsonParser<Map<String,String>>();
            parser.fromJson(rawMappingJson,"err");

            var imageCacheMapping = SynchronizedMap.from(parser.value);
            _observer.on_next(json);
            _observer.on_completed();
            return Subscription.empty();
        });
        
        /*.map((v:api.models.JsonModels.RootFriendsData)->{
            var arrFriend = [];
            for (rawFriend in v.friends) {
                arrFriend.push(new FriendModel(rawFriend.nickName,rawFriend.profileImageUrl,rawFriend.id,rawFriend.profileImageLocalUrl));
            }
            return arrFriend;
        });//.subscribe(observ);*/

//        var apiAndStorage = apiFriendsCall.combineLatest([storageApiCall], combinator);

        //apiAndStorage.subscribe(Observer.create(()->{},(e)->{},(v)->{trace(v);}));

        /*new SubscribeOnThis(Scheduler.newThread,
            Observable.create(_observer -> {
                trace('performing some long running task on ${ Thread.current() }...${ threadID == Thread.current() }');
                var anotherID = Thread.current();
                trace("another thread: " + anotherID);
                _observer.on_next([Std.random(10), Std.random(10), Std.random(10)]);
                _observer.on_completed();

                return Subscription.empty();
            })
        ).subscribe(observ);*/
        
        //.subscribeOn(threadScheduler)
        //.observeOn(mainSheduler);
            //.subscribe(observ);
			//.subscribeOn(threadScheduler)
			//.observeOn(mainSheduler)
			//.subscribeFunction((_v:Array<Int>) -> printArray(_v));
            // Create two subscriptions to prove the replay subject works.
            //rep.subscribeFunction(printArray);
            //rep.subscribeFunction(printArray);

            // Give some time for the task to run then read a message as a function and execute it.
            // This function will pump the observer events to the two subscribers.
            
           // final func : () -> Void = Thread.readMessage(false);
           // func();

            //rep.subscribeFunction(printArray);


            /*
        apiFriendsCall.subscribe(Observer.create(
                function(){  
                    trace("completed");
                },
                function(e){
                    trace("err " + e);
                },
                function(v:Dynamic){ 
                    trace("Val: "+ v);
                    //observer.on_next(v); 
                }
        ));*/
        
        //menuView = this;//new HeapsMain(provider);//asyncDispatcher);
        //heapsmain.makeInit();
        
        /*
        initECS();
        */
    }
 


    override function init() {
		hxd.Res.initEmbed();
        startup();
        //initServices();
        //initMiniMap();
        //gameObjectManager = new GameObjectManagerService();

        var tt:Object3DView = new Object3DView(null);

        var instance = hxd.Window.getInstance();
        renderTarget = new Texture(engine.width,engine.height, [ Target ]);
        s3dTarget = new h3d.scene.Scene();
        var zoom = 10;
        s3dTarget.camera.orthoBounds = Bounds.fromValues(
            -instance.width / zoom / 2,
            -instance.height / zoom / 2,
            -99,
            instance.width / zoom,
            instance.height / zoom,
            999
        );
        s3dTarget.camera.target.set(0, 0, 0);
        s3dTarget.camera.pos.load(s3dTarget.camera.target.add(new h3d.Vector(0, 0, 1)));

        var planeprim = new Plane3D(50);
        planeprim.unindex();
        planeprim.addNormals();
        planeprim.addUVs();
        //get our image resource and convert it into a texture
        var tex = hxd.Res.images.minimap.toTexture();

        // create a material with this texture
        var mat = h3d.mat.Material.create(tex);
        mat.blendMode = Alpha;
        /*
        var miniMapObject = new h3d.scene.Mesh(planeprim,mat,s3dTarget);
        miniMapObject.material.castShadows = false;
        miniMapObject.setPosition(0,0,0);
        miniMapObject.scale(0.5 + Math.random() * 40);*/
	    //renderTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);

        

        s3d.camera.pos.set(100, 20, 80);

        
         //Math.min(instance.height, instance.width) / 2;
        //s3dTarget.camera.pos.set(100,20,120);
        

        

        //s3dTarget.camera.
        controller = new h3d.scene.CameraController(s3d);
        controller.loadFromCamera();

		var prim = new h3d.prim.Grid(100,100,1,1);
		prim.addNormals();
		prim.addUVs();

		var floor = new h3d.scene.Mesh(prim,mat, s3d);
		floor.material.castShadows = false;
		floor.x = -50;
		floor.y = -50;

        var prim2 = new h3d.prim.Grid(200,200,1,1);
		prim2.addNormals();
		prim2.addUVs();

        var floor2 = new h3d.scene.Mesh(prim,mat, s3dTarget);
		floor2.material.castShadows = false;
		floor2.x = -50;
		floor2.y = -50;
        
        
		var box = new h3d.prim.Cube(1,1,1,true);
		box.unindex();
		box.addNormals();
        //tt.set2DRepresentation(box);
        
		for( i in 0...50 ) {
			var m = new h3d.scene.Mesh(box, s3d);
			m.material.color.set(Math.random(), Math.random(), Math.random());
			//m.material.color.normalize();
			m.scale(1 + Math.random() * 10);
			m.z = m.scaleX * 0.5;
			m.setRotation(0,0,Math.random() * Math.PI * 2);
			do {
				m.x = Std.random(80) - 40;
				m.y = Std.random(80) - 40;
			} while( m.x * m.x + m.y * m.y < 25 + m.scaleX * m.scaleX );
			m.material.getPass("shadow").isStatic = true;

			var absPos = m.getAbsPos();
			m.cullingCollider = new h3d.col.Sphere(absPos.tx, absPos.ty, absPos.tz, hxd.Math.max(m.scaleZ, hxd.Math.max(m.scaleX, m.scaleY)));
           // movingObjects.push(new MapObject( m, Math.random() * Math.PI * 2, cx , cy , 8 + Math.random() * 50, (0.5 + Math.random()) * 0.2 ));
		}

		var sp = new h3d.prim.Sphere(1,16,16);
		sp.addNormals();
		for( i in 0...20 ) {
            var colorR  = Math.random();
            var colorG  = Math.random();
            var colorB  = Math.random();
            var scaleM  = 0.5 + Math.random() * 4;
            var zM      = 2 + Math.random() * 5;
            var cx      = (Math.random() - 0.5) * 20;
			var cy      = (Math.random() - 0.5) * 20;
            var pos     = Math.random() * Math.PI * 2;
            var ray     = 8 + Math.random() * 50;
            var speed   = (0.5 + Math.random()) * 0.2;
            var gom = new BuildingGameObjectModel(cast(cx,Int));
            

			var m1 = new h3d.scene.Mesh(sp, s3d);
			m1.material.color.set(colorR, colorG, colorB);
			//m.material.color.normalize();
			m1.scale(scaleM);
			m1.z = zM;
			var absPos = m1.getAbsPos();
			m1.cullingCollider = new h3d.col.Sphere(absPos.tx, absPos.ty, absPos.tz, hxd.Math.max(m1.scaleZ, hxd.Math.max(m1.scaleX, m1.scaleY)));
            var gameObj = new GameObject(gom,enums.Relation.ALLY,new Object3DView(m1));
            trace(gameObj.model.getData());
            trace(cast(gameObj.representation3D,h3d.scene.Object));
            //var mapObject = new MapObject( m1, pos, cx , cy , ray, speed );

            var m2 = new h3d.scene.Mesh(sp, s3dTarget);
			m2.material.color.set(colorR, colorG, colorB);
			//m.material.color.normalize();
			m2.scale(scaleM);
			m2.z = zM;
			m2.cullingCollider = new h3d.col.Sphere(absPos.tx, absPos.ty, absPos.tz, hxd.Math.max(m2.scaleZ, hxd.Math.max(m2.scaleX, m2.scaleY)));
          
            var mapObject = new MapObject( m1, pos, cx , cy , ray, speed );
            var miniMapObject = new MiniMapObject(m2, pos, cx, cy, ray, speed);

            movingObjects.push(mapObject);
            objectMapping.set(mapObject,miniMapObject);
            
            //var mm = m.clone();
            //s3dTarget.addChild(m);
            
            //miniMapObjects.push({ m : mm, pos : Math.random() * Math.PI * 2, cx : cx, cy : cy, ray : 8 + Math.random() * 50, speed : (0.5 + Math.random()) * 0.2 });
        };

        Toolkit.init({root: s2d,manualUpdate: false});
        // Add the shadow map view to the UI
		
        /*Storage.getItem("user-settings").handle(function(settings) {
            this.token = token;
        });
        Storage.getItem("user-settings").handle(function(settings) {
            this.token = token;
        });
        */
        
      
        /*client.auth.signInWithEmailAndPassword("wtf@mail.com","123",(res,err)->{
            trace("Good");
        });*/
        //client 
        //client;
        //client.auth.token = "123456";
        //client.auth.onChange(function (user) {
        //    trace('auth.onChange', user);
        //});

        //client.auth.signInAnonymously({something: "hello"},function(err:io.colyseus.error.HttpException, data:Room<State>) {
        //    trace("signInAnonymously => err: " + err.code + ", data: " + data);
        //});
        //client.getAvailableRooms("my_room",function(err:MatchMakeError, room) {
            //trace(err.message);
            //trace(room);
        //});

/*
        client.create("my_room",[],State,function(err:io.colyseus.error.HttpException, room:Room<State>) {
            trace(err.message);
            trace(room);
        });
*/
        
        // room
        
// 		client.joinOrCreate("my_room", [], State, function(err:MatchMakeError, room:Room<State>) {
// 			if (err != null) {
// 				trace(err.message);
// 				return;
// 			}
//             trace("set on add");
            
//             //room.onMessage()

//             room.state.players.onAdd(function(player, sessionId) {
//                 trace("A player has joined! Their unique session id is", sessionId);
//                 var entity = new TestEntity(new h2d.Text(hxd.res.DefaultFont.get(), s2d), player.x, player.y);
//                 cast(entity.getView(),h2d.Text).text = "user: x:"+player.x + " y:"+player.y;
//                 //  "player: x="+player.x + " y="+player.y;  //this.physics.add.image(player.x, player.y, 'ship_0001');
//                 //entity.text = "user: x:"+player.x + " y:"+player.y;
//                 // keep a reference of it on `playerEntities`
//                 if (sessionId == this.room.sessionId) {
//                     this.currentPlayer = entity;
//                     cast(entity.getView(),h2d.Text).textColor = 0x990000;
//                 }
//                 player.onChange((real) -> {
//                     // update local position immediately
                    
//                     entity.setData('serverX',player.x);
//                     entity.setData('serverY',player.y);
//                     cast(entity.getView(),h2d.Text).text = "user: x:"+player.x + " y:"+player.y;
//                 });
//                 this.playerEntities.set(sessionId,entity);
//             });

//             room.state.players.onRemove(function(player, sessionId) {
//                 var entity = this.playerEntities.get(sessionId);
//                 trace("player "+sessionId+" disconnected!");
//                 if (entity != null) {
                    
//                     // destroy entity
//                     s2d.removeChild(entity.getView());
//                     entity = null;
            
//                     // clear local reference
//                     this.playerEntities.remove(sessionId);
//                    // delete this.playerEntities[sessionId];
//                 }
//             });
//             trace(room);
//             //Map.onAdd', v, 'key', k));
// 			// this triggers only when map or array are created with `new`
// 			// when new value appended it is also triggered but traces just empty array
// 			//room.state.container.onChange(function(v) trace('Root.onChange', v));

// 			// following callbacks are never triggered
// 			/*room.state.container.testMap.onChange(function(v, k) trace('Map.onChange', v, 'key', k));
// 			room.state.container.testMap.onAdd(function(v, k) trace('Map.onAdd', v, 'key', k));
// 			room.state.container.testMap.onRemove(function(v, k) trace('Map.onRemove', v, 'key', k));

// 			room.state.container.testArray.onChange(function(v, k) trace('Array.onChange', v, 'key', k));
// 			room.state.container.testArray.onAdd(function(v, k) trace('Array.onAdd', v, 'key', k));
// 			room.state.container.testArray.onRemove(function(v, k) trace('Array.onRemove', v, 'key', k));
// */
// 			this.room = room;
// 		});
        bitmap = new h2d.Bitmap(null, null);
		//bitmap.scale(0.3);
		//bitmap.filter = h2d.filter.ColorMatrix.grayed();
        menuView = new MenuView();
        var hud = new HUD();
        //tt.set2DRepresentation(hud);
        var oob = new h3d.scene.Object(s3d);
        //oob.addChild(box);
        tt.representation3D = movingObjects[0].m;
        //tt.is2d();
        trace("Is 2d: " + tt.is3d);
        bitmap.width = 600;
        bitmap.height = 600;
        hud.mapHolder.addChild(bitmap);
        hud.setMiniMapProjection(bitmap);
        Screen.instance.addComponent(menuView);
        //Screen.instance.addComponent(hud);
        //asyncDispatcher.fire(ev);
        //var win = @:privateAccess hxd.Window.getInstance().window;
        //win.center(); // Relocate window to center of the screen.
        //win.setMinSize(400, 300); // Set minimum possible size of the window.
        //win.setMaxSize(1024, 768); // Set maximum possible size of the window.
        //otherMenu = new BuildingMenu();
        //Screen.instance.addComponent(otherMenu);
        //Window.getInstance().displayMode = Windowed;
        //Window.getInstance().resize(600,350);
        //preloader = new PreloaderView();
        //curView = new MainView();

        //Screen.instance.addComponent(curView);
        //Screen.instance.addComponent(preloader);
        
    }
    function fixedTick(time, dt){
        // send input to the server
        // this.inputPayload.left = hxd.Key.isDown( hxd.Key.LEFT );
        // this.inputPayload.right = hxd.Key.isDown( hxd.Key.RIGHT );
        // this.inputPayload.up = hxd.Key.isDown( hxd.Key.UP );
        // this.inputPayload.down = hxd.Key.isDown( hxd.Key.DOWN );
        // //trace(this.inputPayload);
        // this.room.send(0, this.inputPayload);
        // var velocity = 2;
        // if (this.inputPayload.left) {
        //     this.currentPlayer.setX(this.currentPlayer.getX() - velocity);

        // } else if (this.inputPayload.right) {
        //     this.currentPlayer.setX(this.currentPlayer.getX() + velocity);
        // }

        // if (this.inputPayload.up) {
        //     this.currentPlayer.setY(this.currentPlayer.getY() - velocity);

        // } else if (this.inputPayload.down) {
        //     this.currentPlayer.setY(this.currentPlayer.getY() + velocity);
        // }

        // for (sessionId in playerEntities.keys()) {
        //     // interpolate all player entities
        //     if (sessionId == this.room.sessionId) {
        //         continue;
        //     }
        //     var entity = this.playerEntities.get(sessionId);
        //     var data = entity.getAllData();
        //     var serverX = data.get('serverX');
        //     var serverY = data.get('serverY');
        //     entity.setX(FloatTools.lerp(0.2,entity.getX(),serverX));
        //     entity.setY(FloatTools.lerp(0.2,entity.getY(),serverY));
        // }
    }

    var elapsedTime = .0;
    var fixedTimeStep = 1/60;
    override function render(e:h3d.Engine) {
        // Render the target first
        engine.pushTarget(renderTarget);
    
        engine.clear(0, 1);
        s3dTarget.render(e);
        
        engine.popTarget();
    
        // Now render our scene
        s3d.render(e);
        
        s2d.render(e);
    }
    override function update(dt:Float) {
        BackendImpl.update();
        for( m in movingObjects ) {

			m.pos += m.speed / m.ray;
			m.x = m.cx + Math.cos(m.pos) * m.ray;
			m.y = m.cy + Math.sin(m.pos) * m.ray;

			var cc = Std.downcast(m.cullingCollider, h3d.col.Sphere);
			if( cc != null ) {
				var absPos = m.getAbsPos();
				cc.x = absPos.tx;
				cc.y = absPos.ty;
				cc.z = absPos.tz;
				cc.r = hxd.Math.max(m.scaleZ, hxd.Math.max(m.scaleX, m.scaleY));
			}
            var m2 = objectMapping.get(m);

            m2.pos = m.pos;
            m2.x = m.x;
            m2.y = m.y;
            var cc2 = Std.downcast(m2.cullingCollider, h3d.col.Sphere);
			if( cc2 != null ) {
				var absPos = m2.getAbsPos();
				cc2.x = absPos.tx;
				cc2.y = absPos.ty;
				cc2.z = absPos.tz;
				cc2.r = hxd.Math.max(m2.scaleZ, hxd.Math.max(m2.scaleX, m2.scaleY));
			}
		}
		//var light = lights[curLight];
		//var tex = light == null ? null : light.shadows.getShadowTex();
		bitmap.tile = h2d.Tile.fromTexture(renderTarget);//null;//tex == null || tex.flags.has(Cube) ? null : 
		//inf.text = "Shadows Draw calls: "+ s3d.lightSystem.drawPasses;

		for( o in s3d ) {
			o.culled = false;
		}
        // if (this.room == null) { return; }
        // if (this.currentPlayer == null) { return; }
        
        // //hxd.Timer.elapsedTime
        // //hxd.Timer.lastTimeStamp

        // elapsedTime += dt;
        // while(elapsedTime >= fixedTimeStep){
        //     elapsedTime -= fixedTimeStep;
        //     fixedTick(hxd.Timer.lastTimeStamp, fixedTimeStep);
        // }
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

/*
class SpecificThreadScheduler extends libs.rx.schedulers.MakeScheduler {
	public function new(thread:Thread) {
		super(new SpecificThreadBase(thread));
	}
}

class SpecificThreadBase implements libs.rx.schedulers.Base {
	final thread:Thread;

	public function new(_thread) {
		thread = _thread;
	}

	public function now():Float
		return Timer.stamp();

	public function schedule_absolute (due_time:Float, action:() -> Void):ISubscription {
		final action1 = Utils.createSleepingAction(action, due_time, now());
		final discardable = new DiscardableAction(action1);

		thread.sendMessage(action);

		return discardable.unsubscribe();
	}
}*/
/*
// Cache service for caching friend data
class CacheService {
    constructor() {
        this.cache = new Map();
    }

    isCached(key) {
        return this.cache.has(key);
    }

    cacheResource(key, resource) {
        this.cache.set(key, resource);
    }

    getResource(key) {
        return this.cache.get(key);
    }
}

const cacheService = new CacheService();

// Mock API function to simulate fetching user data
async function fetchUserData() {
    return new Promise((resolve) => {
        setTimeout(() => {
            const friends = [
                { id: 1, name: "Alice", avatar: "https://i.pravatar.cc/150?img=1" },
                { id: 2, name: "Bob", avatar: "https://i.pravatar.cc/150?img=2" },
                { id: 3, name: "Charlie", avatar: "https://i.pravatar.cc/150?img=3" },
                { id: 4, name: "David", avatar: "https://i.pravatar.cc/150?img=4" }
            ];
            resolve(friends);
        }, 2000); // Simulate network delay
    });
}

// Simple hashing function to compare data
function simpleHash(object) {
    return JSON.stringify(object).length.toString(); // Simple hash based on serialized object's length
}

// Load friends with cache management and hash comparison
async function loadFriends() {
    const loadingIndicator = document.getElementById('loading');
    const friendListContainer = document.getElementById('friendList');

    // Show the loading indicator
    loadingIndicator.style.display = 'block';

    const cacheKey = 'friendList';
    const hashKey = 'friendListHash';

    let friends;
    let isDataChanged = false;

    // Check if friends data is already cached
    if (cacheService.isCached(cacheKey)) {
        console.log("Using cached data.");
        friends = cacheService.getResource(cacheKey);
        
        // Compare current data hash with cached hash
        const currentHash = simpleHash(friends);
        
        if (cacheService.isCached(hashKey)) {
            const cachedHash = cacheService.getResource(hashKey);
            // If hashes differ, data has changed in the outer system
            if (cachedHash !== currentHash) {
                console.log("Data has changed externally, refreshing list.");
                isDataChanged = true;
            }
        }
        
        if (!isDataChanged) {
            loadingIndicator.style.display = 'none'; // Hide loading indicator
            return renderFriends(friends);
        }
    }

    try {
        friends = await fetchUserData(); // Fetch user data from the mock API
        loadingIndicator.style.display = 'none'; // Hide loading indicator

        // Cache the retrieved friends data and their hash
        cacheService.cacheResource(cacheKey, friends);
        cacheService.cacheResource(hashKey, simpleHash(friends));
        renderFriends(friends);
    } catch (error) {
        console.error("Error loading friends:", error);
        loadingIndicator.textContent = 'Failed to load friends.';
    }
}

// Render the friends list in the DOM
function renderFriends(friends) {
    const friendListContainer = document.getElementById('friendList');
    friendListContainer.innerHTML = ''; // Clear the container before rendering new friends
    friends.forEach(friend => {
        const friendDiv = document.createElement('div');
        friendDiv.classList.add('friend');
        friendDiv.innerHTML = `
            <img src="${friend.avatar}" alt="${friend.name}'s avatar">
            <span>${friend.name}</span>
        `;
        friendListContainer.appendChild(friendDiv);
    });
}

// Add a new friend to the list and update cache
function addFriend(name, avatar) {
    const friends = cacheService.isCached('friendList') ? cacheService.getResource('friendList') : [];
    const newFriend = { id: friends.length + 1, name, avatar };
    friends.push(newFriend);
    cacheService.cacheResource('friendList', friends);
    cacheService.cacheResource('friendListHash', simpleHash(friends)); // Update hash
    renderFriends(friends);
}

// Remove a friend from the list and update cache
function removeFriend(friendId) {
    const friends = cacheService.isCached('friendList') ? cacheService.getResource('friendList') : [];
    const updatedFriends = friends.filter(friend => friend.id !== friendId);
    cacheService.cacheResource('friendList', updatedFriends);
    cacheService.cacheResource('friendListHash', simpleHash(updatedFriends)); // Update hash
    renderFriends(updatedFriends);
}

// Call the function to load friends on page load
loadFriends();
*/