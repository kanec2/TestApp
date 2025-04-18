package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;

class Defer<T> extends Observable<T> {
    var _observableFactory:Void -> Observable<T>;

    public function new(observableFactory:Void -> Observable<T>) {
        super();
        _observableFactory = observableFactory;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var _source:Observable<T> = null;
        try {
            _source = _observableFactory();
        }
        catch (ex:String) {
            throw ex;

            //_source = Observable.error(ex); //error why
        }
        return _source.subscribe(observer);
    }
}
 