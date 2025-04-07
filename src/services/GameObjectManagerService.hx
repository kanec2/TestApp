package services;
import ui.views.HUD;
import hx.injection.Service;

class GameObjectManagerService implements IGameObjectManagerService{
	public var gameObjects:List<GameObject>;
   
	public function removeObject(object:GameObject) {
        gameObjects.remove(object);
    }
	public function addObject(object:GameObject) {
        gameObjects.add(object);
    }

    public function new() {}
}