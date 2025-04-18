package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Binary;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class SkipUntil<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _other:IObservable<T>;

    public function new(source:IObservable<T>, other:IObservable<T>) {
        super();
        _source = source;
        _other = other;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        //lock
        var triggered = false;
        var otherSubscription = SingleAssignment.create();
        var other_observer = Observer.create(
            function() {
                triggered = true;
                otherSubscription.unsubscribe();
            },
            function(e:String) {
                triggered = true;
                otherSubscription.unsubscribe();
            },
            function(v:T) {
                triggered = true;
                otherSubscription.unsubscribe();
            }
        );
        otherSubscription.set(_other.subscribe(other_observer));
        var skipUntil_observer = Observer.create(
            function() {
                if (triggered)
                    observer.on_completed();
            },
            function(e:String) {
                if (triggered)
                    observer.on_error(e);
            },
            function(v:T) {
                if (triggered)
                    observer.on_next(v);
            }
        );
        var sourceSubscription = _source.subscribe(skipUntil_observer);
        return Binary.create(sourceSubscription, otherSubscription);
    }
}
 