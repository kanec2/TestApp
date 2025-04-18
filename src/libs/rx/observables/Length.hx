package libs.rx.observables;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;
/** Implementation based on:
   * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Linq/Observable/Count.cs
   *
   */
class Length<T> extends Observable<Int> {
    var _source:IObservable<T>;

    public function new(source:IObservable<T>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<Int>):ISubscription {

        var counter = AtomicData.create(0);
        var length_observer = Observer.create(function() {
            var v = AtomicData.unsafe_get(counter);
            observer.on_next(v);
            observer.on_completed();
        }, observer.on_error, function(v:T) {
            AtomicData.update(Utils.succ, counter);
        });

        return _source.subscribe(length_observer);
    }
}
 