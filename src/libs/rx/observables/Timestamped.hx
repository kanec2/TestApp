package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Scheduler;
class Timestamped<T> {
    public var value:T;
    public var timestamp:Float;

    public function new(value:T, timestamp:Float) {
        this.value = value;
        this.timestamp = timestamp;
    }
}