import ui.views.MainView;
import ui.views.MenuVIew;
import haxe.ui.HaxeUIApp;
import systems.Render3D;
import ecs.Workflow;
import components.ResourceComponent;
import components.*;
import ecs.Entity;

class Main{
    public function new() {
        trace("Start ecs things");
        Workflow.addSystem(new Render3D());
        Workflow.addSystem(new systems.UISystem());
        Workflow.addSystem(new systems.ResourceProduce());
        var player:Entity = new Entity();

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
    public static function main(){
        new Main();
    }
}