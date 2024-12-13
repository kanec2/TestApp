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

class Main{
    static var friends:SynchronizedArray<FriendModel>;
    var menuView:MenuView;
    var getFriendsExecutor:Executor;
    var usersGetUrl = "http://localhost:5017/arnest/api/get-running-machine-checks-devices";//"http://jsonplaceholder.typicode.com/users";
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
        /*
        for(friend in newfriends){
           //Sys.sleep(2);
           friends.add(friend);
           var idx = friends.indexOf(friend);
           trace("done");
           
           menuView.setFriends(friends);
           
           
        };*/
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

    function createLoadImageTask(url:String):Void->Variant{
        return ()->{
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
    }


    public static function main(){
        new Main();
    }
}