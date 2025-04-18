package libs.rx.observables;

import libs.rx.disposables.Composite;
import libs.rx.disposables.SingleAssignment;
import libs.rx.observables.BufferCount.BufferState;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;

class BufferWhen<T> extends Observable<Array<T>> {

	var _source : IObservable<T>;
	var _closingSelector : () -> IObservable<T>;


	public function new( source : IObservable<T>, closingSelector : () -> IObservable<T> ) {
		super();
		_source = source;
		_closingSelector = closingSelector;
	}

	override public function subscribe( observer : IObserver<Array<T>> ) : ISubscription {
		var state = AtomicData.create( { list : new Array<T>() } );

		var __unsubscribe = Composite.create();
		var selectorSubscription : ISubscription = null;

		var observerSource = Observer.create(
			function () {
				selectorSubscription.unsubscribe();
				observer.on_completed();
			},
			observer.on_error,
			function ( v : T ) {
				AtomicData.update(
					function ( s : BufferState<T> ) {
						s.list.push( v );
						return s;
					}, state );
			}
		);

		var observerNotifier : Observer<T> = null;
		observerNotifier = Observer.create(
			function () {
				trace("completed buffer");
				observer.on_next( AtomicData.unsafe_get( state ).list );
			},
			function ( e : String ) {
				observer.on_next( AtomicData.unsafe_get( state ).list );
			},
			function ( v : T ) {
				AtomicData.update(
					( s : BufferState<T> ) -> {
						selectorSubscription.unsubscribe();
						selectorSubscription = _closingSelector().subscribe( observerNotifier );
						__unsubscribe.add( selectorSubscription );
						observer.on_next( s.list );
						s.list = new Array<T>();
						return s;
					},
					state
				);
			}
		);

		__unsubscribe.add( _source.subscribe( observerSource ) );
		selectorSubscription = _closingSelector().subscribe( observerNotifier );
		__unsubscribe.add( selectorSubscription );

		return __unsubscribe;
	}
}
