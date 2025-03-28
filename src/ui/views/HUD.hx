package ui.views;

import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Box;
import Math;
@:build(haxe.ui.ComponentBuilder.build("assets/ui/views/hud.xml"))
class HUD extends Box{

    var mapObjects = new Array<Dynamic>();
    var minimap : h2d.Bitmap;
    public function new() {
        super();
        this.mapObjects = generateRandomObjects();
        //miniMap.setMapObjects(mapObjects);
        trace(this.mapObjects);
    }
    public function setMiniMapProjection(bitmap:h2d.Bitmap){
        this.minimap = bitmap;
        //this.minimap.width = this.mapHolder.width;
        //this.minimap.height = this.mapHolder.height;
    }

    @:bind(this.mapHolder,UIEvent.RESIZE)
    function onRes(e){
        trace(e);
        if(this.minimap != null && this.mapHolder != null){
            trace(' w: ${this.mapHolder.actualComponentWidth}, h: ${this.mapHolder.actualComponentHeight}');
            this.minimap.width = this.mapHolder.actualComponentWidth;//this.mapHolder.width;
            this.minimap.height = this.mapHolder.actualComponentHeight;//this.mapHolder.height;
            //trace(e.value);
        }
    }

    function generateRandomObjects(){
        var arr = new Array();
        for (i in 0...14) {
            var relation = "";
            var roll = Math.random();
            if(roll < 0.35) relation = "ALLY";
            else if (roll < 0.70) relation = "ENEMY";
            else relation = "NEUTURAL";

            var obj = {relation: relation, x: Math.random()*30, y: Math.random()*30};
            arr.push(obj);
        }
        return arr;
    }

    function makeRandomStep(){
        for(obj in mapObjects){
            var dx = Math.random() * 10;
            var dy = Math.random() * 10;
            if(Math.random() > 0.5) dx = dx * -1;
            if(Math.random() > 0.5) dy = dy * -1;
            obj.x+=dx;
            obj.y+=dy;
        }
    }

    @:bind(inc, MouseEvent.CLICK)
    private function incf(_) {
        trace("WEWE");
        makeRandomStep();
        //miniMap.setMapObjects(mapObjects);
    }
}