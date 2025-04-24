package libs.rx.observables;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import hx.concurrent.executor.Executor;
import hx.concurrent.CountDownLatch;

class SubscribeOn<T> extends Observable<T> {
    public var source:IObservable<T>;
    public var executor:Executor;

    public function new(source:IObservable<T>, executor:Executor) {
        super();
        this.source = source;
        this.executor = executor;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var sub:ISubscription;

        // we need to hold a reference to the source subscription
        // but subscription can only happen asynchronously on the executor

        // Promise-like or manual signalling is *not* provided,
        // so we create a simple synchronization using CountDownLatch or similar.

        // Since Haxe concurrency lib has CountDownLatch, use it.
        

        var latch = new CountDownLatch(1);

        executor.submit(() -> {
            sub = source.subscribe(observer);
            latch.countDown();
        });

        // Wait for subscription before returning to ensure hot observables are attached properly.
        // But this *will block* the calling thread — 
        // depending on usage, you may want a fully async solution.

        latch.await();

        return sub;
    }
}