package libs.rx.observables;


import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import hx.concurrent.executor.Executor;
import hx.concurrent.executor.ThreadPoolExecutor;

class ObserveOn<T> extends Observable<T> {
    public var source:IObservable<T>;
    public var executor:Executor;

    public function new(source:IObservable<T>, executor:Executor) {
        super();
        this.source = source;
        this.executor = executor;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        // Wrap the observer to schedule notifications on executor
        var scheduledObserver = new ScheduledObserver<T>(observer, executor);

        // Subscribe to the source observable
        var sourceSub = source.subscribe(scheduledObserver);
        return sourceSub;
    }
}