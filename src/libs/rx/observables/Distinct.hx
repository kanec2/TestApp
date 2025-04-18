package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;


class Distinct<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _comparer:T -> T -> Bool;

    public function new(source:IObservable<T>, comparer:T -> T -> Bool) {
        super();
        _source = source;
        _comparer = comparer;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var values = new List<T>();
        var distinct_observer = Observer.create(function() {
            observer.on_completed();
        },
        observer.on_error,
        function(v:T) {
            var hasValue = Lambda.exists(values, function(x) {
                return _comparer(x, v);
            });
            if (!hasValue) {
                observer.on_next(v);
                values.add(v);
            }
        });

        return _source.subscribe(distinct_observer);
    }
}
 