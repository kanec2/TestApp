package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;

class Return<T> extends Observable<T> {
    var v:T;

    public function new(v:T) {
        super();
        this.v = v;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        observer.on_next(v);
        observer.on_completed();
        return Subscription.empty();
    }
}