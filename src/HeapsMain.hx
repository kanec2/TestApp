import hx.injection.Service;
import hx.injection.ServiceCollection;
import services.GameObjectManagerService;
import h3d.col.Bounds;
import h3d.mat.Texture;
import h3d.prim.Cube;
import ui.views.HUD;
import ui.views.BuildingMenu;
import ui.views.MainView;
import extensions.Auth;
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
import Main.AppEventBase;
import io.colyseus.Client;
import io.colyseus.Room;

import tweenxcore.structure.FloatChange;
import tweenxcore.structure.FloatChangePart;
import services.AppEventService;

using tweenxcore.Tools;
using hx.injection.ServiceExtensions;
class HeapsMain extends hxd.App {
    var worldController : WorldController;
    var uiController : UIController;

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
    var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    var userToken:String;

    var serviceProvider: hx.injection.ServiceProvider;
    
    var auth = new Auth("localhost", 2567);
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
    public function setFriends(friends:SynchronizedArray<FriendModel>){
        //trace("CALLED");
        var arr:Array<FriendModel> = new Array<FriendModel>();
        for (friend in friends)
            arr.push(friend);
        menuView.setFriends(arr);
    }
    /*
    public static function main(asyncDispatcher:AsyncEventDispatcher<AppEventBase>) {
		new HeapsMain(asyncDispatcher);
	}*/
    var ev:AppEventBase = {
        event: "AppInited",
        data: null
    }
    
    public function new(serviceProvider: hx.injection.ServiceProvider) {
        super();
        this.serviceProvider = serviceProvider;
        var appEventService:AppEventService = serviceProvider.getService(AppEventService);
        this.asyncDispatcher = appEventService.asyncDispatcher;
        asyncDispatcher.subscribe(onLogin);
        asyncDispatcher.subscribe(onRegister);
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

    function register(email,pass){
        trace("try to register");

        var token:String = "";
        var userData:Dynamic = null;
        auth.registerWithEmailAndPassword("wtf22@mail.com", "123", (regErr, regData) ->{
            if(regErr!=null){
                asyncDispatcher.fire({
                    event: "RegisterFailure",
                    data: regErr.message
                });
            }
            if(regData != null){
                token = regData.token;
                userData = regData.user;
                asyncDispatcher.fire({
                    event: "RegisterSucessful",
                    data: token
                });
            }
        });
    }
    var renderTarget:Texture;
    var s3dTarget:h3d.scene.Scene;
    function signIn(email,pass){
        trace("try to login");
        
        auth.signInWithEmailAndPassword("wtf22@mail.com", "123", (err, data) ->{
            trace("Auth?");
            if(err != null){
                asyncDispatcher.fire({
                    event: "LoginFailure",
                    data: err.message
                });
            }
            if(data != null){
                trace(data);
                asyncDispatcher.fire({
                    event: "LoginSucessful",
                    data: data.token
                });
            }
        });
    }

    function initMiniMap() {
        
    }

    function initServices(){
        //var collection = new ServiceCollection();
        //collection.addSingleton(GameObjectManagerService);
        //var provider = collection.createProvider();
        gameObjectManager = serviceProvider.getService(GameObjectManagerService);
    }

    public function makeInit(){
        setup();
        //init();
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
            register("wtf22@mail.com", "123");
        }
        catch(e){ trace("register failed"); }

        try {
            signIn("wtf22@mail.com", "123");
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
        asyncDispatcher.fire(ev);
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

}