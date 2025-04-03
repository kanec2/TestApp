package services;

import hx.injection.Service;
interface IGameObjectManagerService extends Service {
    var gameObjects:List<GameObject>;
    var scene3D:h3d.scene.Scene;
    var scene2D:h2d.Scene;

    function removeObject(object:GameObject):Void;
    function addObject(object:GameObject):Void;
        
    /*{
        this.gameObjects.push(object);
        object.addToScene(this.scene); // Add to the Three.js scene
    }*/
}