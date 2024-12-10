package systems;

import components.Position;
import h3d.scene.Scene;
import h3d.scene.Object;
import ecs.System;

class Render3D extends System {
    var scene3D:Scene;

    public function new() {
        
    }

    function onObjectAdded(object:Object) {
        scene3D.addChild(object);
    }
    function onObjectRemoved(object:Object){
        scene3D.removeChild(object);
    }
    function onPositionUpdate(object:Object,position:Position) {
        object.x = position.x;
        object.y = position.y;
        object.z = position.z;
    }
}