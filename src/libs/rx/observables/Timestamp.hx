package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Composite;
import libs.rx.disposables.SerialAssignment;
import libs.rx.Subscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.schedulers.IScheduler;

//todo test
class Timestamp<T> extends Observable<Timestamped<T>> {
    var _source:IObservable<T>;
    var _scheduler:IScheduler;

    public function new(source:IObservable<T>, scheduler:IScheduler) {
        super();
        _source = source;
        _scheduler = scheduler;
    }

    override public function subscribe(observer:IObserver<Timestamped<T>>):ISubscription {


        var timestamp_observer = Observer.create(
            function() {
                observer.on_completed();
            },
            function(e:String) {
                observer.on_error(e);
            },
            function(v:T) {
                observer.on_next(new Timestamped<T>(v, _scheduler.now()));
            }
        );


        return _source.subscribe(timestamp_observer);
    }
}
 