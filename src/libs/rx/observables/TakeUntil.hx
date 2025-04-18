package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Binary;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class TakeUntil<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _other:IObservable<T>;

    public function new(source:IObservable<T>, other:IObservable<T>) {
        super();
        _source = source;
        _other = other;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var otherSubscription = SingleAssignment.create();
        var other_observer = Observer.create(
            function() {
                observer.on_completed();
                otherSubscription.unsubscribe();
            },
            function(e:String) {
                observer.on_completed();
                otherSubscription.unsubscribe();
            },
            function(v:T) {
                observer.on_completed();
                otherSubscription.unsubscribe();
            }
        );

        otherSubscription.set(_other.subscribe(other_observer));
        var takeUntil_observer = Observer.create(
            function() {
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);
            },
            function(v:T) {
                observer.on_next(v);
            }
        );
        var sourceSubscription = _source.subscribe(takeUntil_observer);
        return Binary.create(sourceSubscription, otherSubscription);
    }
}
 