package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class Filter<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _predicate:T -> Bool;

    public function new(source:IObservable<T>, predicate:T -> Bool) {
        super();
        _source = source;
        _predicate = predicate;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var filter_observer = Observer.create(
            function() {
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);

            },
            function(value:T) {
                var isPassed = false;
                try {
                    isPassed = _predicate(value);
                }
                catch (ex:String) {
                    observer.on_error(ex);
                    return;
                }
                if (isPassed) {
                    observer.on_next(value);
                }
            }
        );
        return _source.subscribe(filter_observer);
    }
}
 