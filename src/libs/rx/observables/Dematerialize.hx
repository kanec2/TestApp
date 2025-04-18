package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
/* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationDematerialize.java
   */
class Dematerialize<T> extends Observable<T> {
    var _source:IObservable<Notification<T>>;

    public function new(source:IObservable<Notification<T>>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var materialize_observer = Observer.create(null, null,
        function(v:Notification<T>) {
            switch(v ) {
                case OnCompleted:{

                    observer.on_completed();
                }
                case OnError(e):{
                    observer.on_error(e);
                }
                case OnNext(vv) :{
                    observer.on_next(vv);
                }
                default: {

                }
            };
        }
        );
        return _source.subscribe(materialize_observer);
    }
}
 