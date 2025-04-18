package libs.rx.observables;

import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Composite;
import libs.rx.disposables.SerialAssignment;
import libs.rx.Subscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.Observer;
import libs.rx.schedulers.IScheduler;

typedef ThrottleState<T> = {
	var latestValue : Null<T>;
	var hasValue : Bool;
	var id : Float;
}

// todo test
class Throttle<T> extends Observable<T> {

	var _source : IObservable<T>;
	var _scheduler : IScheduler;
	var _dueTime : Float;

	public function new( source : IObservable<T>, dueTime : Float, ?scheduler : IScheduler ) {
		super();
		_source = source;
		_dueTime = dueTime;
		_scheduler = scheduler == null ? Scheduler.timeBasedOperations : scheduler;
	}

	override public function subscribe( observer : IObserver<T> ) : ISubscription {
		// lock
		var __subscription = Composite.create();
		var cancelable = SerialAssignment.create();
		__subscription.add( cancelable );

		var state = AtomicData.create( {
			latestValue : null,
			hasValue : false,
			id : 0.0
		} );
		function __on_next( currentid : Float ) {
			// lock
			AtomicData.update_if(
				function ( s : ThrottleState<T> ) {
					return s.hasValue && s.id == currentid;
				},
				function ( s : ThrottleState<T> ) {
					observer.on_next( s.latestValue );
					s.hasValue = false;
					return s;
				}, state );
		};

		var throttle_observer = Observer.create(
			function () {
				// lock
				cancelable.unsubscribe();
				AtomicData.update( function ( s : ThrottleState<T> ) {
					if ( s.hasValue ) {
						observer.on_next( s.latestValue );
					}
					s.hasValue = false;
					s.id = s.id + 1;
					return s;
				}, state );
				observer.on_completed();
			},
			function ( e : String ) {
				// lock
				cancelable.unsubscribe();
				AtomicData.update( function ( s : ThrottleState<T> ) {
					s.hasValue = false;
					s.id = s.id + 1;
					return s;
				}, state );
				observer.on_error( e );
			},
			function ( value : T ) {
				// trace( "throttle next!" );
				var currentid : Float = 0;
				AtomicData.update( function ( s : ThrottleState<T> ) {
					s.hasValue = true;
					s.latestValue = value;
					s.id = s.id + 1;
					currentid = s.id;
					return s;
				}, state );
				var d = _scheduler.schedule_relative( _dueTime, function () {
					trace( "relative delay executed" );
					__on_next( currentid );
					return Subscription.empty();
				} );
				cancelable.set( d );
			}
		);

		__subscription.add( _source.subscribe( throttle_observer ) );
		return __subscription;
	}
}
