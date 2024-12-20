import hx.concurrent.event.AsyncEventDispatcher;
import haxe.ui.backend.BackendImpl;
import ui.models.FriendModel;
import hx.concurrent.collection.SynchronizedArray;
import haxe.ui.core.Screen;
import ui.views.MenuVIew;
import haxe.ui.Toolkit;
import Main.AppEventBase;
class HeapsMain extends hxd.App {
    public var menuView:MenuView;
    var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
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
    }
}