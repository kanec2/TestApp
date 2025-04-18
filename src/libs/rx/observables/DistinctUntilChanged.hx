package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;


class DistinctUntilChanged<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _comparer:T -> T -> Bool;

    public function new(source:IObservable<T>, comparer:T -> T -> Bool) {
        super();
        _source = source;
        _comparer = comparer;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var isFirst = true;
        var prevKey:Null<T> = null;
        var onNextWarp = function(value:T) {
            var currentKey:Null<T> = null;
            try {
                currentKey = value;
            }
            catch (exception:String) {
                observer.on_error(exception);
                return;
            }
            var sameKey = false;
            if (isFirst) {
                isFirst = false;
            }
            else {
                try {
                    sameKey = _comparer(currentKey, prevKey);
                }
                catch (ex:String) {
                    observer.on_error(ex);
                    return;
                }
            }

            if (!sameKey) {
                prevKey = currentKey;
                observer.on_next(value);
            }
        };
        var distinctUntilChanged_observer = Observer.create(observer.on_completed, observer.on_error, onNextWarp);

        return _source.subscribe(distinctUntilChanged_observer);
    }
}
 