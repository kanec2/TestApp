package services;

import ui.views.HUD;

import hx.injection.Service;
interface IGameObjectManagerService extends Service {
    var gameObjects:List<GameObject>;

    function removeObject(object:GameObject):Void;
    function addObject(object:GameObject):Void;
        
    /*{
        this.gameObjects.push(object);
        object.addToScene(this.scene); // Add to the Three.js scene
    }*/
}