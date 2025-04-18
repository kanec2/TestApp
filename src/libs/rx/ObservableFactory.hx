package libs.rx;

import haxe.extern.EitherType;
import haxe.Constraints.Function;
import libs.rx.observables.BufferWhen;
import libs.rx.observables.BufferCount;
import libs.rx.Core.RxObserver;
import libs.rx.Core.RxSubscription;
// Creating Observables
import libs.rx.observables.Create;
// create an Observable from scratch by calling observer methods programmatically
import libs.rx.observables.Defer;
//  — do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
import libs.rx.observables.Empty;
import libs.rx.observables.Never;
import libs.rx.observables.Error;
//  — create Observables that have very precise and limited behavior
// From;// — convert some other object or data structure into an Observable
// Interval;//  — create an Observable that emits a sequence of integers spaced by a particular time interval
// Just;//  — convert an object or a set of objects into an Observable that emits that or those objects
// Range;//  — create an Observable that emits a range of sequential integers
// Repeat;//  — create an Observable that emits a particular item or sequence of items repeatedly
// Start;//  — create an Observable that emits the return value of a function
// Timer;//  — create an Observable that emits a single item after a given delay
import libs.rx.observables.Empty;
import libs.rx.observables.Error;
import libs.rx.observables.Never;
import libs.rx.observables.Return;
import libs.rx.observables.Append;
import libs.rx.observables.Dematerialize;
import libs.rx.observables.Skip;
import libs.rx.observables.Length;
import libs.rx.observables.Map;
import libs.rx.observables.Materialize;
import libs.rx.observables.Merge;
import libs.rx.observables.Single;
import libs.rx.observables.Take;
import libs.rx.observables.TakeLast;
// 7-31
import libs.rx.observables.Average;
import libs.rx.observables.Amb;
import libs.rx.observables.Buffer;
import libs.rx.observables.Catch;
import libs.rx.observables.CombineLatest;
import libs.rx.observables.Concat;
import libs.rx.observables.Contains;
// 8-1
import libs.rx.observables.Defer;
import libs.rx.observables.Create;
import libs.rx.observables.Throttle;
import libs.rx.observables.DefaultIfEmpty;
import libs.rx.observables.Timestamp;
import libs.rx.observables.Delay;
import libs.rx.observables.Distinct;
import libs.rx.observables.DistinctUntilChanged;
import libs.rx.observables.Filter;
import libs.rx.observables.Find;
import libs.rx.observables.ElementAt;
// 8-2
import libs.rx.observables.First;
import libs.rx.observables.Last;
import libs.rx.observables.IgnoreElements;
import libs.rx.observables.SkipUntil;
import libs.rx.observables.Scan;
// 8-3
import libs.rx.observables.TakeUntil;
import libs.rx.observables.MakeScheduled;
import libs.rx.observables.Blocking;
import libs.rx.observables.CurrentThread;
import libs.rx.observables.Immediate;
import libs.rx.observables.NewThread;
import libs.rx.observables.Test;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.schedulers.IScheduler;

typedef Signal<T> = {
	function add( callback : ( T ) -> Void ) : Signal<T>;
	function remove( callback : EitherType<Bool, ( T ) -> Void> ) : Void;
}

class ObservableFactory {

	static public function ofIterable<T>( __args : Iterable<T> ) : Observable<T> {
		return new Create( function ( observer : IObserver<T> ) {
			for ( i in __args ) {
				observer.on_next( i );
			}
			observer.on_completed();
			return Subscription.empty();
		} );
	}

	static public function find<T>( observable : Observable<T>, comparer : Null<T -> Bool> ) {
		return new Find( observable, comparer );
	}

	static public function filter<T>( observable : Observable<T>, comparer : Null<T -> Bool> ) {
		return new Filter( observable, comparer );
	}

	static public function distinctUntilChanged<T>( observable : Observable<T>, ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new DistinctUntilChanged( observable, comparer );
	}

	static public function distinct<T>( observable : Observable<T>, ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new Distinct( observable, comparer );
	}

	static public function delay<T>( source : Observable<T>, dueTime : Float, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Delay<T>( source, haxe.Timer.stamp() + dueTime, scheduler );
	}

	static public function timestamp<T>( source : Observable<T>, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Timestamp<T>( source, scheduler );
	}

	static public function scan<T, R>( observable : Observable<T>, seed : Null<R>, accumulator : R -> T -> R ) {
		return new Scan( observable, seed, accumulator );
	}

	static public function last<T>( observable : Observable<T>, ?source : Null<T> ) {
		return new Last( observable, source );
	}

	static public function first<T>( observable : Observable<T>, ?source : Null<T> ) {
		return new First( observable, source );
	}

	static public function defaultIfEmpty<T>( observable : Observable<T>, source : T ) {
		return new DefaultIfEmpty( observable, source );
	}

	static public function contains<T>( observable : Observable<T>, source : T ) {
		return new Contains( observable, function ( v ) return v == source );
	}

	static public function concat<T>( observable : Observable<T>, source : Array<Observable<T>> ) {
		return new Concat( [observable].concat( source ) );
	}

	static public function combineLatest<T, R>( observable : Observable<T>, source : Array<Observable<T>>, combinator : Array<T> -> R ) {
		return new CombineLatest( [observable].concat( source ), combinator );
	}

	public static function interval( period : Float, ?scheduler : IScheduler ) {
		return new SubscribeInterval( period, scheduler );
	}

	static public function of_catch<T>( observable : Observable<T>, errorHandler : String -> Observable<T> ) {
		return new Catch( observable, errorHandler );
	}

	static public function bufferWhen<T>( observable : Observable<T>, closingSelector : () -> IObservable<T> ) {
		return new BufferWhen( observable, closingSelector );
	}

	static public function bufferCount<T>( observable : Observable<T>, count : Int ) {
		return new BufferCount( observable, count );
	}

	static public function observer<T>( observable : Observable<T>, fun : T -> Void ) {
		return observable.subscribe( Observer.create( null, null, fun ) );
	}

	static public function amb<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Amb( observable1, observable2 );
	}

	static public function average<T>( observable : Observable<T> ) {
		return new Average( observable );
	}

	static public function materialize<T>( observable : Observable<T> ) {
		return new Materialize( observable );
	}

	static public function dematerialize<T>( observable : Observable<Notification<T>> ) {
		return new Dematerialize( observable );
	}

	static public function length<T>( observable : Observable<T> ) {
		return new Length( observable );
	}

	static public function skip<T>( observable : Observable<T>, n : Int ) {
		return new Skip( observable, n );
	}

	static public function skip_until<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new SkipUntil( observable1, observable2 );
	}

	static public function take<T>( observable : Observable<T>, n : Int ) {
		return new Take( observable, n );
	}

	static public function take_until<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new TakeUntil( observable1, observable2 );
	}

	static public function take_last<T>( observable : Observable<T>, n : Int ) {
		return new TakeLast( observable, n );
	}

	static public function single<T>( observable : Observable<T> ) {
		return new Single( observable );
	}

	static public function append<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Append( observable1, observable2 );
	}

	static public function map<T, R>( observable : Observable<T>, f : T -> R ) {
		return new Map( observable, f );
	}

	static public function merge<T>( observable : Observable<Observable<T>> ) {
		return new Merge( observable );
	}

	static public function flatMap<T, R>( observable : Observable<T>, f : T -> Observable<R> ) {
		return bind( observable, f );
	}

	static public function bind<T, R>( observable : Observable<T>, f : T -> Observable<R> ) {
		return merge( map( observable, f ) );
	}

	/*public static function fromSignal<T>( signal : signals.Signal<T> ) : Observable<T> {
		return new rx.observables.Signal( signal );
	}*/
}
