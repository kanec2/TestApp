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


import hx.injection.Service;
import hx.injection.ServiceCollection;
import services.GameObjectManagerService;
import h3d.col.Bounds;
import h3d.mat.Texture;
import h3d.prim.Cube;
import ui.views.HUD;
import ui.views.BuildingMenu;
import ui.views.MainView;

import haxe.ui.backend.heaps.KeyboardHelper;
import hxd.Key;
import io.colyseus.error.MatchMakeError;
import hx.concurrent.event.AsyncEventDispatcher;
import haxe.ui.backend.BackendImpl;
import ui.models.FriendModel;
import hx.concurrent.collection.SynchronizedArray;
import haxe.ui.core.Screen;
import ui.views.MenuVIew;
import haxe.ui.Toolkit;
import io.colyseus.Client;
import io.colyseus.Room;

import tweenxcore.structure.FloatChange;
import tweenxcore.structure.FloatChangePart;
import services.AppEventService;
import services.GameObjectManagerService;
import services.AuthenticationService;

import enums.AppEvent;

using tweenxcore.Tools;
using hx.injection.ServiceExtensions;


//https://gigglingcorpse.com/2021/11/22/hello-world-heaps-on-android/
class Main extends hxd.App {
    static var friends:SynchronizedArray<FriendModel>;
    //var menuView:MenuView;
    //var menuView:HeapsMain;
    //var getFriendsExecutor:Executor;
    //var usersGetUrl = "http://localhost:5017/arnest/api/get-running-machine-checks-devices";
    var usersGetUrl = "http://jsonplaceholder.typicode.com/users";
    //var appInitEvent:AppEventBase;
    var friendsLoadedEvent:AppEventBase;
    var executor:Executor;
    var appInited:Bool = false;
    //var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    var cacheFolder:Dir;
    var appFolder:Dir;

    var imageCacheMapping:SynchronizedMap<String,String>;
    var imageCachePath:Path;
    var imageMappingFile:File;
    
    var collection:ServiceCollection;

    var worldController : WorldController;
    var uiController : UIController;

    var gameObjectManager : GameObjectManagerService;

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
    var appEventService             :AppEventService;
    var gameObjectManagerService    :GameObjectManagerService;
    var authenticationService       :AuthenticationService;

    public function setFriends(friends:SynchronizedArray<FriendModel>){
        //trace("CALLED");
        var arr:Array<FriendModel> = new Array<FriendModel>();
        for (friend in friends)
            arr.push(friend);
        menuView.setFriends(arr);
    }
    function onLogin(event:AppEventBase){
        if(event.event != "LoginFailure" || event.event != "LoginSucessful") return;

        if(event.event == "LoginSucessful"){
            userToken = event.data;
            trace(userToken);
        }
    }

    function onRegister(event:AppEventBase){
        if(event.event != "RegisterFailure" || event.event != "RegisterSucessful") return;

        if(event.event == "RegisterSucessful"){
            userToken = event.data;
            trace(userToken);
        }
    }

    
    var renderTarget:Texture;
    var s3dTarget:h3d.scene.Scene;
    
    public function new() {
        initServices();
        var provider = collection.createProvider();
        var appEventService = provider.getService(AppEventService);
        //var heapsmain = provider.getService(HeapsMain);
        
        Toolkit.onAfterInit = startup;
        friends = new SynchronizedArray<FriendModel>();
        executor = Executor.create(5);
        //asyncDispatcher = appEventService.asyncDispatcher;//new AsyncEventDispatcher<AppEventBase>(executor);
        appEventService.subscribe(onFriendsLoaded);
        appEventService.subscribe(onAppInited);
        //new HeapsMain(provider);
        super();
        //menuView = this;//new HeapsMain(provider);//asyncDispatcher);
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
        //collection.addSingleton(HeapsMain);
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
        if(event.event != AppEvent.FRIENDS_LOADED) return;
        if(!appInited) return;
        //menuView.setFriends(friends);
    }

    function onAppInited(event:AppEventBase){
        if(event.event != AppEvent.INITED) return;
        //trace("App inited");
        appInited = true;
        //if(friends != null) menuView.setFriends(friends);
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

    override function init() {
		hxd.Res.initEmbed();
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
        
        try {
            authenticationService.register("wtf22@mail.com", "123");
        }
        catch(e){ trace("register failed"); }

        try {
            authenticationService.signIn("wtf22@mail.com", "123");
        }
        catch(e){ trace("login failed"); }
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
        //Screen.instance.addComponent(menuView);
        Screen.instance.addComponent(hud);
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
            var ev:AppEventBase = { event: enums.AppEvent.FRIENDS_LOADED, data: null};
            appEventService.dispatch(ev);
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
            var ev:AppEventBase = { event: AppEvent.FRIENDS_LOADED, data: null };
            appEventService.dispatch(ev);
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
                        //menuView.setFriends(friends);
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
                //menuView.setFriends(friends);
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