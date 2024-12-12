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
    public function new() {
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
        var app = new HaxeUIApp();
        app.ready(function() {
            HaxeUIApp.instance.icon = "assets/images/favicon.png";
            HaxeUIApp.instance.title = "GoodGames | Community and Store HTML Game Template";
            app.addComponent(new MenuView());

            app.start();
        });
    }

    function getFriendList(userId:String){
        /*var executor = Executor.create(3);  // <- 3 means to use a thread pool of 3 threads on platforms that support threads
      // depending on the platform either a thread-based or timer-based implementation is returned

      // define a function to be executed concurrently/async/scheduled (return type can also be Void)
      var myTask = function():Date {
         trace("Executing...");
         return Date.now();
      }

      // submit 10 tasks each to be executed once asynchronously/concurrently as soon as possible
      for (i in 0...10) {
         executor.submit(myTask);
      }

      executor.submit(myTask, ONCE(2000));            // async one-time execution with a delay of 2 seconds
      executor.submit(myTask, FIXED_RATE(200));       // repeated async execution every 200ms
      executor.submit(myTask, FIXED_DELAY(200));      // repeated async execution 200ms after the last execution
      executor.submit(myTask, HOURLY(30));            // async execution 30min after each full hour
      executor.submit(myTask, DAILY(3, 30));          // async execution daily at 3:30
      executor.submit(myTask, WEEKLY(SUNDAY, 3, 30)); // async execution Sundays at 3:30

      // submit a task and keep a reference to it
      var future = executor.submit(myTask, FIXED_RATE(200));

      // check if a result is already available
      switch (future.result) {
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