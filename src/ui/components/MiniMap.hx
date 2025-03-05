package ui.components;

import haxe.ui.util.Variant;
import hxd.Res;
import haxe.ui.Toolkit;
import haxe.ui.components.Canvas;

class MiniMap extends Canvas {
    var _miniMapImage:Variant;
    public var miniMapImage(get,set):Variant;
    public function new() {
        super();
        
        frame();
    }
    var cx = 1;
    var mapObjects:Array<Dynamic> = new Array<Dynamic>();
	function get_miniMapImage():Variant {
		return _miniMapImage;
	}

	function set_miniMapImage(value:Variant):Variant {
		_miniMapImage = value;
        return _miniMapImage;
	}

    public function setMapObjects(objArray:Array<Dynamic>){
        this.mapObjects = objArray;
        //trace(this.mapObjects);
    }

    private function frame() {
        if (_isDisposed) {
            return;
        }
        
        componentGraphics.clear();
        //trace(mapObjects);

        
        if(mapObjects.length > 0) {
            
            componentGraphics.strokeStyle("#407ec9", 1);
            componentGraphics.fillStyle("white");

            componentGraphics.image(_miniMapImage,200,200,500,500);
            for(i in 0...mapObjects.length){
                var obj = mapObjects[i];
                var ox:Int = obj.x;
                var oy:Int = obj.y;

                switch(obj.relation){
                    case "ALLY" : componentGraphics.fillStyle("green"); 
                    case "ENEMY" : componentGraphics.fillStyle("red"); 
                    case "NEUTURAL" : componentGraphics.fillStyle("gray"); 
                }
                componentGraphics.circle(ox,oy,3);
                /*
                var obj = mapObjects[i];
                switch(obj.relation){
                    case "ALLY" : componentGraphics.fillStyle("green"); break;
                    case "ENEMY" : componentGraphics.fillStyle("red"); break;
                    case "NEUTURAL" : componentGraphics.fillStyle("gray"); break;
                }
                //var ox = Math.round(obj.x);
                //var oy = Math.round(obj.y);
                //trace(ox);
                //trace(oy);
                componentGraphics.circle(i*4,i*7,30);*/
            }
        }
        Toolkit.callLater(frame);
    }


}