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

class Main{
    static var friends:SynchronizedArray<FriendModel>;
    var menuView:MenuView;
    public function new() {
        trace("Start ecs things");
        
        friends = new SynchronizedArray<FriendModel>();
        
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
        var app = new HaxeUIApp();
        app.ready(function() {
            menuView = new MenuView();
            menuView.init(getFriendList);//,getFriendList);
            HaxeUIApp.instance.icon = "assets/images/favicon.png";
            HaxeUIApp.instance.title = "GoodGames | Community and Store HTML Game Template";
            app.addComponent(menuView);

            app.start();
        });
    }
    function gg():Void {
        var unused:hx.concurrent.Future.FutureCompletionListener<Void> = null;
        var newfriends = new Array<FriendModel>();
        newfriends.push(new FriendModel("qwe","https://placehold.co/32x32/orange/white/png","1"));
        newfriends.push(new FriendModel("bvc","adq","2"));
        newfriends.push(new FriendModel("zxc","bbb","3"));
        for(friend in newfriends){
           //Sys.sleep(2);
           friends.add(friend);
           var idx = friends.indexOf(friend);
           trace("done");
           
           menuView.setFriends(friends);
           
           
        };
        friends = friends.map((friend:FriendModel)->{
        try{
            trace(friend.profileImageUrl);
            if(friend.profileImageUrl != null){
            ImageLoader.instance.load(friend.profileImageUrl,(inf:ImageInfo)->{
            trace(inf);
            if(inf != null && inf.data != null){
                friend.image = inf.data;
                //friends[idx].image = inf.data;
                //menuView.setFriends(friends);
                
            }
        });
    }
        }
        return friend;
    });
    menuView.setFriends(friends);
     }
    function getFriendList(userId:String){
        var executor = Executor.create(3);  // <- 3 means to use a thread pool of 3 threads on platforms that support threads
      // depending on the platform either a thread-based or timer-based implementation is returned
      var unused:hx.concurrent.Future.FutureCompletionListener<Void> = null;
      // define a function to be executed concurrently/async/scheduled (return type can also be Void)
        var urls = ["https://placehold.co/32x32/orange/white/png","https://placehold.co/32x32/orange/green/png","https://placehold.co/32x32/blue/green/png"];
        for(url in urls){
            var task:Void->Variant = ()->{
                var imgData:Variant = null;
                var compl:Bool = false;
                ImageLoader.instance.load(url,(inf:ImageInfo)->{
                    
                    if(inf != null && inf.data != null) { trace(inf.data); imgData = inf.data;}
                    trace("agagaga: "+imgData);
                    compl = true;
                });
                while(!compl) Sys.sleep(0.2);
                return imgData;
            };
            
            var future = executor.submit(task);
            future.onCompletion(result->{
                switch(result) {
                    case VALUE(value, time, _): {
                        trace(value.toImageData());
                        trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
                    }
                    case FAILURE(ex, time, _):  trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
                    case PENDING(_):      trace("Nothing is happening");
                  }
            });
            switch (future.result) {
                case VALUE(value, time, _): trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
                case FAILURE(ex, time, _):  trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
                case PENDING(_):            trace("No result yet...");
             }
        }

      // submit 10 tasks each to be executed once asynchronously/concurrently as soon as possible
      //for (i in 0...10) {
         //executor.submit(gg);
      //}

      /*executor.submit(myTask, ONCE(2000));            // async one-time execution with a delay of 2 seconds
      executor.submit(myTask, FIXED_RATE(200));       // repeated async execution every 200ms
      executor.submit(myTask, FIXED_DELAY(200));      // repeated async execution 200ms after the last execution
      executor.submit(myTask, HOURLY(30));            // async execution 30min after each full hour
      executor.submit(myTask, DAILY(3, 30));          // async execution daily at 3:30
      executor.submit(myTask, WEEKLY(SUNDAY, 3, 30)); // async execution Sundays at 3:30

      // submit a task and keep a reference to it
      var future = executor.submit(myTask, FIXED_RATE(200));
*/
      // check if a result is already available
      /*switch (future.result) {
         case VALUE(value, time, _): trace('Successfully execution at ${Date.fromTime(time)} with result: $value');
         case FAILURE(ex, time, _):  trace('Execution failed at ${Date.fromTime(time)} with exception: $ex');
         case PENDING(_):            trace("No result yet...");
      }

      // check if the task is scheduled to be executed (again) in the future
      if (!future.isStopped) {
         trace('The task is scheduled for further executions with schedule: ${future.schedule}');
      }

      // cancel any future execution of the task
      future.cancel();*/
    }


    public static function main(){
        new Main();
    }
}