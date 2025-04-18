package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.Observer;
import libs.rx.schedulers.IScheduler;
//type +'a observable = 'a observer -> subscription
/* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationMaterialize.java
   */

class ObserveOnThis<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _scheduler : IScheduler;

    public function new(source:IObservable<T>, scheduler : IScheduler) {
        super();
        _source     = source;
        _scheduler  = scheduler;
    }

    override public function subscribe(observer : IObserver<T>) : ISubscription
    {
        var schedule_observer = Observer.create(function() {
            _scheduler.schedule_absolute(0, observer.on_completed);
        }, function(e:String) {
            _scheduler.schedule_absolute(0, observer.on_error.bind(e));
        }, function(v:T) {
            _scheduler.schedule_absolute(0, observer.on_next.bind(v));
        }
        );
        return _source.subscribe(schedule_observer);
    }
}