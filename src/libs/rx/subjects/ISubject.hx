package libs.rx.subjects;
import libs.rx.observables.IObservable;
import libs.rx.observers.IObserver;
interface ISubject<T> extends IObservable<T> extends IObserver<T> {

}