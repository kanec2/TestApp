package systems;

import components.Product;
import components.PlayerComponent;
import components.ResourceComponent;
import ecs.View;
import ecs.System;

class ResourceProduce extends ecs.System {
    var players:View<PlayerComponent, ResourceComponent>;
/*
    @:added function onEntityAdded() {
        
    }
    @:removed function onEntityRemoved() {

    }*/
    @:u function produce(product:Product){
        // Add resource to the player
        var p = players.entities.iterator();
        for (player in p){
            trace("pl: "+player);
        }
        /*var existingResource = player.Resources.FirstOrDefault(r => r.ResourceType == resource.ResourceType);

        if (existingResource != null)
        {
            existingResource.Amount += resource.Amount; // Accumulate the resource
        }
        else
        {*/
            /*
            // If the resource is not present, add a new one
            player.Resources.Add(new ResourceComponent
            {
                ResourceType = resource.ResourceType,
                Amount = resource.Amount
            });*/
        //}
    }
}