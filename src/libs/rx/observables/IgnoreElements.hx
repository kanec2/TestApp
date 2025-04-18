package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class IgnoreElements<T> extends Observable<T> {
    var _source:IObservable<T>;

    public function new(source:IObservable<T>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var ignoreElements_observer = Observer.create(
            function() {
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);
            },
            function(v:T) {

            }
        );
        return _source.subscribe(ignoreElements_observer);
    }
}
 