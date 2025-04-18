package libs.rx.observables;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
interface IObservable<T> {
    public function subscribe(observer:IObserver<T>):ISubscription;
}