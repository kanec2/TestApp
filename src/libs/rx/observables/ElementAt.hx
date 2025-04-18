package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class ElementAt<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _index:Int;

    public function new(source:IObservable<T>, index:Int) {
        super();
        _source = source;
        _index = index;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        //lock
        var counter = AtomicData.create(0);
        var __subscription = SingleAssignment.create();
        var elementAt_observer = Observer.create(
            function() {
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);

            },
            function(value:T) {
                AtomicData.update_if(function(c:Int) return c == _index,
                function(c:Int) {
                    observer.on_next(value);
                    observer.on_completed();
                    __subscription.unsubscribe();
                    return c;
                },
                counter);
                AtomicData.update(Utils.succ, counter);
            }
        );
        __subscription.set(_source.subscribe(elementAt_observer));
        return __subscription;
    }
}
 