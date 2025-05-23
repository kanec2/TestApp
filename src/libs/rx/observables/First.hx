package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class First<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _defaultValue:Null<T>;

    public function new(source:IObservable<T>, defaultValue:Null<T>) {
        super();
        _source = source;
        _defaultValue = defaultValue;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var notPublished:Bool = true;
        var first_observer = Observer.create(
            function() {
                if (notPublished) {
                    if (_defaultValue != null) {
                        observer.on_next(_defaultValue);
                    }
                    else {
                        observer.on_error("sequence is empty");
                    }
                }
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);
            },
            function(v:T) {
                if (notPublished) {
                    notPublished = false;
                    observer.on_next(v);
                    observer.on_completed();
                }
            }
        );
        return _source.subscribe(first_observer);
    }
}
 