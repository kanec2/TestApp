package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;
/*
   */
class Map<T, R> extends Observable<R> {
    var _source:IObservable<T>;
    var _f:T -> R;

    public function new(source:IObservable<T>, f:T -> R) {
        super();
        _source = source;
        _f = f;
    }

    override public function subscribe(observer:IObserver<R>):ISubscription {
        var map_observer = Observer.create(
            observer.on_completed,
            observer.on_error,
            function(v:T) {
                observer.on_next(_f(v));
            }
        );
        return _source.subscribe(map_observer);
    }
}
 