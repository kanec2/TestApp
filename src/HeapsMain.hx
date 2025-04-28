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
import network.states.State;
import tweenxcore.structure.FloatChange;
import tweenxcore.structure.FloatChangePart;

using tweenxcore.Tools;

class HeapsMain extends hxd.App {
    public var menuView:MenuView;
    var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    private var client:Client = null;
    private var room: Room<State>;
    //var playerEntities:
    var endpoint = "ws://localhost:2567";
    var currentPlayer: TestEntity;
    //var remoteRef: Phaser.GameObjects.Rectangle;
    // we will assign each player visual representation here
    // by their `sessionId`
    var playerEntities:Map<String,TestEntity> = new Map<String,TestEntity>();// {[sessionId: string]: any} = {};
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
    public static function main(asyncDispatcher:AsyncEventDispatcher<AppEventBase>) {
		new HeapsMain(asyncDispatcher);
	}
    var ev:AppEventBase = {
        event: "AppInited",
        data: null
    }
    
    public function new(asyncDispatcher:AsyncEventDispatcher<AppEventBase>) {
        super();
        this.asyncDispatcher = asyncDispatcher;
    }

    override function init() {
		hxd.Res.initEmbed();
		Toolkit.init({root: s2d,manualUpdate: false});
        var vv = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        vv.text= "dsadwq";
        //client 
        var client = new Client("localhost",2567);//client;
        //client.auth.token = "123456";
        //client.auth.onChange(function (user) {
        //    trace('auth.onChange', user);
        //});

        //client.auth.signInAnonymously({something: "hello"},function(err:io.colyseus.error.HttpException, data:Room<State>) {
        //    trace("signInAnonymously => err: " + err.code + ", data: " + data);
        //});
        client.getAvailableRooms("my_room",function(err:MatchMakeError, room) {
            //trace(err.message);
            //trace(room);
        });

/*
        client.create("my_room",[],State,function(err:io.colyseus.error.HttpException, room:Room<State>) {
            trace(err.message);
            trace(room);
        });
*/
        
        // room
        
		client.joinOrCreate("my_room", [], State, function(err:MatchMakeError, room:Room<State>) {
			if (err != null) {
				trace(err.message);
				return;
			}
            trace("set on add");
            
            //room.onMessage()

            room.state.players.onAdd(function(player, sessionId) {
                var entity = new TestEntity(new h2d.Text(hxd.res.DefaultFont.get(), s2d), player.x, player.y);
                cast(entity.getView(),h2d.Text).text = "user: x:"+player.x + " y:"+player.y;
                //  "player: x="+player.x + " y="+player.y;  //this.physics.add.image(player.x, player.y, 'ship_0001');
                //entity.text = "user: x:"+player.x + " y:"+player.y;
                // keep a reference of it on `playerEntities`
                
                trace("A player has joined! Their unique session id is", sessionId);
                if (sessionId == this.room.sessionId) {
                    // this is the current player!
                    // (we are going to treat it differently during the update loop)
                    this.currentPlayer = entity;
                    cast(entity.getView(),h2d.Text).textColor = 0xff0000;
                    // remoteRef is being used for debug only
                    //this.remoteRef = this.add.rectangle(0, 0, entity.width, entity.height);
                    //this.remoteRef.setStrokeStyle(1, 0xff0000);
                }
                else {
                        player.onChange((real) -> {
                        // update local position immediately
                        
                        entity.setData('serverX',player.x);
                        entity.setData('serverY',player.y);
                        cast(entity.getView(),h2d.Text).text = "user: x:"+player.x + " y:"+player.y;
                    });
                }
                this.playerEntities.set(sessionId,entity);
            });

            room.state.players.onRemove(function(player, sessionId) {
                var entity = this.playerEntities.get(sessionId);
                
                if (entity != null) {
                    
                    // destroy entity
                    //entity.destroy();
            
                    // clear local reference
                    this.playerEntities.remove(sessionId);
                   // delete this.playerEntities[sessionId];
                }
            });
            trace(room);
            //Map.onAdd', v, 'key', k));
			// this triggers only when map or array are created with `new`
			// when new value appended it is also triggered but traces just empty array
			//room.state.container.onChange(function(v) trace('Root.onChange', v));

			// following callbacks are never triggered
			/*room.state.container.testMap.onChange(function(v, k) trace('Map.onChange', v, 'key', k));
			room.state.container.testMap.onAdd(function(v, k) trace('Map.onAdd', v, 'key', k));
			room.state.container.testMap.onRemove(function(v, k) trace('Map.onRemove', v, 'key', k));

			room.state.container.testArray.onChange(function(v, k) trace('Array.onChange', v, 'key', k));
			room.state.container.testArray.onAdd(function(v, k) trace('Array.onAdd', v, 'key', k));
			room.state.container.testArray.onRemove(function(v, k) trace('Array.onRemove', v, 'key', k));
*/
			this.room = room;
		});

        menuView = new MenuView();
        Screen.instance.addComponent(menuView);
        asyncDispatcher.fire(ev);
        //Window.getInstance().displayMode = Windowed;
        //Window.getInstance().resize(600,350);
        //preloader = new PreloaderView();
        //curView = new MainView();

        //Screen.instance.addComponent(curView);
        //Screen.instance.addComponent(preloader);
        
    }
    function fixedTick() {
        //
        // paste the previous `update()` implementation here!
        //
        if (this.currentPlayer == null) { return; }
        if (this.room == null) { return; }
        var velocity = 2;
        // send input to the server
        this.inputPayload.left = hxd.Key.isDown( hxd.Key.LEFT );
        this.inputPayload.right = hxd.Key.isDown( hxd.Key.RIGHT );
        this.inputPayload.up = hxd.Key.isDown( hxd.Key.UP );
        this.inputPayload.down = hxd.Key.isDown( hxd.Key.DOWN );
        //trace(this.inputPayload);
        this.room.send(0, this.inputPayload);
        if (this.inputPayload.left) {
            this.currentPlayer.setX(this.currentPlayer.getX() - velocity);
    
        } else if (this.inputPayload.right) {
            this.currentPlayer.setX(this.currentPlayer.getX() + velocity);
        }
    
        if (this.inputPayload.up) {
            this.currentPlayer.setY(this.currentPlayer.getY() - velocity);
    
        } else if (this.inputPayload.down) {
            this.currentPlayer.setY(this.currentPlayer.getY() + velocity);
        }
        for (sessionId in playerEntities.keys()) {
            // interpolate all player entities
            // do not interpolate the current player
            if (sessionId == this.room.sessionId) {
                continue;
            }
            var entity = this.playerEntities.get(sessionId);
            var data = entity.getAllData();
            var serverX = data.get('serverX');
            var serverY = data.get('serverY');
            //const { serverX, serverY } = entity.data.values;
            entity.setX(FloatTools.lerp(0.2,entity.getX(),serverX));
            entity.setY(FloatTools.lerp(0.2,entity.getY(),serverY));
            /*
            entity.setX()
            entity.x = Phaser.Math.Linear(entity.x, serverX, 0.2);
            entity.y = Phaser.Math.Linear(entity.y, serverY, 0.2);*/
        }
    }

    var elapsedTime = 0;
    var fixedTimeStep = 1000 / 60;

    override function update(dt:Float) {
        BackendImpl.update();
        if (!this.currentPlayer) { return; }

    this.elapsedTime += dt;
    while (this.elapsedTime >= this.fixedTimeStep) {
        this.elapsedTime -= this.fixedTimeStep;
        this.fixedTick(time, this.fixedTimeStep);
    }
    }

}