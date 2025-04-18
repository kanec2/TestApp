package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.disposables.SingleAssignment;
import libs.rx.disposables.Composite;
/**

      var observer = Observer.create(
                function(){  
                },
                function(e){

                },
                function(v:T){ 
                    observer.on_next(v); 
                }
         );
**/
class Create<T> extends Observable<T> {
    var _subscribe:IObserver<T> -> ISubscription;

    public function new(_subscribe:IObserver<T> -> ISubscription) {
        this._subscribe = _subscribe;
        super();
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        return _subscribe(observer);
    }
}
