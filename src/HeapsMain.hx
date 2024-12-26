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
class HeapsMain extends hxd.App {
    public var menuView:MenuView;
    var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    private var client:Client = null;
    private var room: Room<State>;
    //var playerEntities:
    var endpoint = "ws://localhost:2567";

    // we will assign each player visual representation here
    // by their `sessionId`
    var playerEntities:Map<String,String> = new Map<String,String>();// {[sessionId: string]: any} = {};
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
            trace(err.message);
            trace(room);
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
            
            room.state.players.onAdd(function(player, sessionId) {
                var entity = "player: x="+player.x + " y="+player.y;  //this.physics.add.image(player.x, player.y, 'ship_0001');

                // keep a reference of it on `playerEntities`
                this.playerEntities.set(sessionId,entity);
                trace("A player has joined! Their unique session id is", sessionId);
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

    override function update(dt:Float) {
        BackendImpl.update();
        
        if (this.room == null) { return; }

        // send input to the server
        this.inputPayload.left = hxd.Key.isDown( hxd.Key.LEFT );
        this.inputPayload.right = hxd.Key.isDown( hxd.Key.RIGHT );
        this.inputPayload.up = hxd.Key.isDown( hxd.Key.UP );
        this.inputPayload.down = hxd.Key.isDown( hxd.Key.DOWN );
        this.room.send(0, this.inputPayload);
    }
}