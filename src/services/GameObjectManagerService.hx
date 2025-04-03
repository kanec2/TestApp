package services;
import hx.injection.Service;

class GameObjectManagerService implements IGameObjectManagerService{
	public var gameObjects:List<GameObject>;
    public var scene3D:h3d.scene.Scene;
    public var scene2D:h2d.Scene;

	public function removeObject(object:GameObject) {
        gameObjects.remove(object);
    }
	public function addObject(object:GameObject) {
        gameObjects.add(object);
    }

    public function new() {}
}