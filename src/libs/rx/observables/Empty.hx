package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
class Empty<T> extends Observable<T> {
    public function new() {
        super();
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        observer.on_completed();
        return Subscription.empty();
    }
}