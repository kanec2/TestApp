package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.disposables.SingleAssignment;
import libs.rx.disposables.Composite;
class Amb<T> extends Observable<T> {
    var _source1:IObservable<T>;
    var _source2:IObservable<T>;

    public function new(source1:IObservable<T>, source2:IObservable<T>) {
        super();
        _source1 = source1;
        _source2 = source2;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        if (_source2 == null) return _source1.subscribe(observer);

        var subscriptionA = SingleAssignment.create();
        var subscriptionB = SingleAssignment.create();
        var __unsubscribe = Composite.create();
        __unsubscribe.add(subscriptionA);
        __unsubscribe.add(subscriptionB);

        inline function unsubscribeA() { subscriptionA.unsubscribe();};
        inline function unsubscribeB() { subscriptionB.unsubscribe();};
		
        var observerA = Observer.create(
            function() {
                unsubscribeB();
                observer.on_completed();
            },
            function(e:String) {
                unsubscribeB();
                observer.on_error(e);
            },
            function(v:T) {
                unsubscribeB();
                observer.on_next(v);
            }
        );
        var observerB = Observer.create(
            function() {
                unsubscribeA();
                observer.on_completed();
            },
            function(e:String) {
                unsubscribeA();
                observer.on_error(e);
            },
            function(v:T) {
                unsubscribeA();
                observer.on_next(v);
            }
        );
        subscriptionA.set(_source1.subscribe(observerA));
        subscriptionB.set(_source2.subscribe(observerB));

        return __unsubscribe;

    }
}
 