package libs.rx.observables;

import hx.concurrent.executor.Executor;
import libs.rx.observers.IObserver;

class ScheduledObserver<T> implements IObserver<T> {
    var actual:IObserver<T>;
    var executor:Executor;

    public function new(actual:IObserver<T>, executor:Executor) {
        this.actual = actual;
        this.executor = executor;
    }

    public function on_next(t:T):Void {
        executor.submit(() -> {
            actual.on_next(t);
        });
    }

    public function on_error(error:Dynamic):Void {
        executor.submit(() -> {
            actual.on_error(error);
        });
    }

    public function on_completed():Void {
        executor.submit(() -> {
            actual.on_completed();
        });
    }
}