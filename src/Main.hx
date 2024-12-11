import ui.views.MainView;
import ui.views.MenuVIew;
import haxe.ui.HaxeUIApp;
import systems.Render3D;
import ecs.Workflow;

class Main{
    public function new() {
        trace("Hi");
        Workflow.addSystem(new Render3D());
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