package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Scheduler;

class Immediate extends MakeScheduled {
    public function new() {
        super();
        scheduler = Scheduler.immediate;
    }
}