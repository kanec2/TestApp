package libs.rx.observables;

import libs.rx.observers.IObserver;
import libs.rx.disposables.ISubscription;

class EndWith<T> extends Observable<T> {

	var _source : IObservable<T>;
	var valueEnd : T;

	public function new( source : IObservable<T>, valueEnd : T ) {
		super();
		_source = source;
		this.valueEnd = valueEnd;
	}

	override public function subscribe( observer : IObserver<T> ) : ISubscription {
		var notPublished : Bool = true;

		var distinct_observer = Observer.create(
			function () {
				observer.on_completed();

				observer.on_next(valueEnd);
			},
			observer.on_error,
			function ( v : T ) {
				notPublished = false;
				observer.on_next( v );
			}
		);

		return _source.subscribe( distinct_observer );
	}
}
