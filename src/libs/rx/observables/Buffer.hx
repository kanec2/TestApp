package libs.rx.observables;

import libs.rx.disposables.Composite;
import libs.rx.disposables.ISubscription;
import libs.rx.observables.BufferCount.BufferState;
import libs.rx.observers.IObserver;

class Buffer<T> extends Observable<Array<T>> {

	var _source : IObservable<T>;
	var _closingNotifier : IObservable<T>;

	public function new( source : IObservable<T>, closingNotifier : IObservable<T> ) {
		super();
		_source = source;
		_closingNotifier = closingNotifier;
	}

	override public function subscribe( observer : IObserver<Array<T>> ) : ISubscription {
		var state = AtomicData.create( { list : new Array<T>() } );

		var __unsubscribe = Composite.create();

		var observerSource = Observer.create(
			observer.on_completed,
			observer.on_error,
			function ( v : T ) {
				AtomicData.update(
					function ( s : BufferState<T> ) {
						s.list.push( v );
						return s;
					}, state );
			}
		);

		var observerNotifier = Observer.create(
			function () {
				observer.on_next( AtomicData.unsafe_get( state ).list );
			},
			function ( e : String ) {
				observer.on_next( AtomicData.unsafe_get( state ).list );
			},
			function ( v : T ) {
				AtomicData.update(
					( s : BufferState<T> ) -> {
						observer.on_next( s.list );
						s.list = new Array<T>();
						return s;
					},
					state
				);
			}
		);

		__unsubscribe.add( _source.subscribe( observerSource ) );
		__unsubscribe.add( _closingNotifier.subscribe( observerNotifier ) );
		
		return __unsubscribe;
	}
}
