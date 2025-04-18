package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Composite;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class Append<T> extends Observable<T> {
    var _source1:IObservable<T>;
    var _source2:IObservable<T>;

    public function new(source1:IObservable<T>, source2:IObservable<T>) {
        super();
        _source1 = source1;
        _source2 = source2;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var __unsubscribe = Composite.create();
        var o1_observer = Observer.create(
            function() {
                __unsubscribe.add(_source2.subscribe(observer));
            },
            observer.on_error,
            function(v:T) {
                observer.on_next(v);
            }
        );

        __unsubscribe.add(_source1.subscribe(o1_observer));
        return __unsubscribe;
    }
}
 