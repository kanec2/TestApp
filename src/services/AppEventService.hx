package services;

import hx.concurrent.executor.Executor;
import Main.AppEventBase;
import hx.concurrent.event.AsyncEventDispatcher;
import haxe.Constraints.Function;
import hx.injection.Service;

class AppEventService implements Service{
    public var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    public function new() {
        var executor = Executor.create(3);
        this.asyncDispatcher = new AsyncEventDispatcher<AppEventBase>(executor);
        //this.asyncDispatcher = asyncDispatcher;
    }   
    public function subscribe(callback:Function){
        
    }
}