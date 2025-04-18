package libs.rx.observables;

import libs.rx.disposables.Composite;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.Utils;

/*  (* Implementation based on:
	* https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationSkip.java
	*)
 */
class Skip<T> extends Observable<T> {

	var _source : IObservable<T>;
	var n : Int;

	public function new( source : IObservable<T>, n : Int ) {
		super();
		_source = source;
		this.n = n;
	}

	override public function subscribe( observer : IObserver<T> ) : ISubscription {
		var counter = AtomicData.create( 0 );
		var drop_observer = Observer.create( observer.on_completed, observer.on_error,
			function ( v : T ) {
				var count = AtomicData.update_and_get( Utils.succ, counter );
				if ( count > n ) observer.on_next( v );
			} );

		var composite = Composite.create();
		composite.add( Subscription.create(() -> {
			trace( "skip sub removed" );} ) );
		composite.add( _source.subscribe( drop_observer ) );

		return composite;
	}
}
