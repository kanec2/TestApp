package components;

import ecs.Entity;
import haxe.ds.List;

class PlayerComponent {
    public var playerEntity:Entity ; // Reference to the player entity
    public var resources:List<ResourceComponent>; // List of resources owned by the player

    public function new(playerEntity:Entity, resources:List<ResourceComponent>) {
        this.playerEntity = playerEntity;
        this.resources = resources;
    }
}