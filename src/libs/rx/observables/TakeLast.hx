package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;
/*   (* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationTakeLast.java
   *)
   */
class TakeLast<T> extends Observable<T> {
    var _source:IObservable<T>;
    var n:Int;

    public function new(source:IObservable<T>, n:Int) {
        super();
        _source = source;
        this.n = n;

    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var queue = new Array<T>();
        var __unsubscribe = SingleAssignment.create();
        var take_last_observer = Observer.create(function() {
            try {
                for (iter in queue) {
                    observer.on_next(iter) ;
                }
                observer.on_completed();
            } catch (e:String) {
                observer.on_error(e);
            }
        },
        observer.on_error,
        function(v:T) {
            if (n > 0) {
                try {
                    // BatMutex.synchronize
                    queue.push(v);
                    if (queue.length > n) {
                        queue.shift();
                    }
                } catch (e:String) {
                    observer.on_error(e);
                    __unsubscribe.unsubscribe();
                }
            }
        });
        var result = _source.subscribe(take_last_observer);
        __unsubscribe.set(result);
        return result ;

    }
}
 