package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;

class Error<T> extends Observable<T> {
    var err:String;

    public function new(err:String) {
        super();
        this.err = err;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        observer.on_error(err);
        return Subscription.empty();
    }
}