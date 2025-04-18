package libs.rx;
import libs.rx.AtomicData;
import libs.rx.AsyncLock;
import libs.rx.notifiers.Notification;
import libs.rx.Observable;
import libs.rx.Observer;
import libs.rx.Subject;
import libs.rx.Subscription;


typedef RxSubject<T> = RxObserver<T> -> RxObservable<T>;
//type 'a subject = 'a observer * 'a observable
typedef RxObservable<T> = RxObserver<T> -> RxSubscription;
typedef RxSubscription = Void -> Void;
typedef RxObserver<T> = {
    //(unit -> unit) * (exn -> unit) * ('a -> unit)
    var onCompleted:Void -> Void;
    var onError:String -> Void;
    var onNext:T -> Void;
}
 