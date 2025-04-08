package services;

import hx.concurrent.executor.Executor;
import hx.concurrent.event.AsyncEventDispatcher;
import haxe.Constraints.Function;
import hx.injection.Service;
import enums.AppEvent;
typedef AppEventBase = {
    event:AppEvent, 
    data:Dynamic
}
class AppEventService implements Service{
    public var asyncDispatcher:AsyncEventDispatcher<AppEventBase>;
    public function new() {
        var executor = Executor.create(3);
        this.asyncDispatcher = new AsyncEventDispatcher<AppEventBase>(executor);
        //this.asyncDispatcher = asyncDispatcher;
    }   
    public function subscribe(callback:services.AppEventBase -> Void){
        this.asyncDispatcher.subscribe(callback);
    }
    public function dispatch(event:AppEventBase){
        this.asyncDispatcher.fire(event);
    }
}