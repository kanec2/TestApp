package libs.rx;

import hx.concurrent.executor.Executor;
import libs.rx.observables.ObserveOn;
import libs.rx.observables.ObserveOnThis;
import haxe.exceptions.NotImplementedException;
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
import libs.rx.observables.EndWith;
import libs.rx.observables.Test;
import libs.rx.observables.IObservable;
import libs.rx.disposables.ISubscription;
import libs.rx.observers.IObserver;
import libs.rx.notifiers.Notification;
import libs.rx.schedulers.IScheduler;

// type +'a observable = 'a observer -> subscription
/*Internal module. (see Rx.Observable)
 *
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/Observable.java
 */
class Observable<T> implements IObservable<T> {

	public function new() {}

	public function subscribe( observer : IObserver<T> ) : ISubscription {
		throw new NotImplementedException();
	}
	public static var currentThread : CurrentThread = new CurrentThread();
	public static var newThread : NewThread = new NewThread();
	public static var immediate : Immediate = new Immediate();
	public static var test : Test = new Test();

	static public function empty<T>() return new Empty<T>();

	static public function error( e : String ) return new Error( e );

	static public function of_never() return new Never();

	static public function of_return<T>( v : T ) return new Return( v );

	static public function create<T>( f : IObserver<T> -> ISubscription ) {
		return new Create( f );
	}

	static public function defer<T>( _observableFactory : Void -> Observable<T> ) {
		return new Defer( _observableFactory );
	}

	static public function of<T>( __args : T ) : Observable<T> {
		return new Return( __args );
	}

	static public function fromRange( ?initial : Null<Int>, ?limit : Null<Int>, ?step : Null<Int> ) {
		if ( limit == null && step == null ) {
			initial = 0;
			limit = 1;
		}
		if ( step == null ) {
			step = 1;
		}
		return Observable.create( function ( observer : IObserver<Int> ) {
			var i = initial;
			while ( i < limit ) {
				observer.on_next( i );
				trace( i );
				i += step;
			}
			observer.on_completed();
			return Subscription.empty();
		} );
	}

	public function find( comparer : Null<T -> Bool> ) {
		return new Find( this, comparer );
	}

	public function filter( comparer : Null<T -> Bool> ) {
		return new Filter( this, comparer );
	}

	public function distinctUntilChanged( ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new DistinctUntilChanged( this, comparer );
	}

	public function distinct( ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new Distinct( this, comparer );
	}

	public function delay( dueTime : Float, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Delay( this, haxe.Timer.stamp() + dueTime, scheduler );
	}

	public function timestamp( source : Observable<T>, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Timestamp( source, scheduler );
	}

	public function scan<R>( seed : Null<R>, accumulator : R -> T -> R ) {
		return new Scan( this, seed, accumulator );
	}

	public function last( ?source : Null<T> ) {
		return new Last( this, source );
	}

	public function endWith( value : T ) {
		return new EndWith( this, value );
	}

	public function first( ?source : Null<T> ) {
		return new First( this, source );
	}

	public function defaultIfEmpty( source : T ) {
		return new DefaultIfEmpty( this, source );
	}

	public function contains( source : T ) {
		return new Contains( this, function ( v ) return v == source );
	}

	public function concat( source : Array<Observable<T>> ) {
		return new Concat( [this].concat( source ) );
	}

	public function combineLatest<R>( source : Array<Observable<T>>, combinator : Array<T> -> R ) {
		return new CombineLatest( [this].concat( source ), combinator );
	}

	public function of_catch( errorHandler : String -> Observable<T> ) {
		return new Catch( this, errorHandler );
	}

	public function buffer( count : Int, closingNotifier : IObservable<T> ) {
		return new Buffer( this, closingNotifier );
	}

	public function bufferCount( count : Int ) {
		return new BufferCount( this, count );
	}

	public function bufferWhen( closingSelector : () -> IObservable<T> ) {
		return new BufferWhen( this, closingSelector );
	}

	public function throttle( dueTime : Float, ?scheduler : IScheduler ) {
		return new Throttle( this, dueTime, scheduler );
	}

	public function observe( fun : T -> Void ) {
		return this.subscribe( Observer.create( null, null, fun ) );
	}

	public function amb( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Amb( observable1, observable2 );
	}

	public function average( observable : Observable<T> ) {
		return new Average( observable );
	}

	public function materialize() {
		return new Materialize( this );
	}

	public function length( observable : Observable<T> ) {
		return new Length( observable );
	}

	public function skip( n : Int ) {
		return new Skip( this, n );
	}

	public function skip_until( observable2 : Observable<T> ) {
		return new SkipUntil( this, observable2 );
	}

	public function take( n : Int ) {
		return new Take( this, n );
	}

	public function take_until( observable2 : Observable<T> ) {
		return new TakeUntil( this, observable2 );
	}

	public function take_last( n : Int ) {
		return new TakeLast( this, n );
	}

	public function append( observable2 : Observable<T> ) {
		return new Append( this, observable2 );
	}

	public function map<R>( f : T -> R ) {
		return new Map( this, f );
	}

	public function bind<R>( f : T -> Observable<R> ) {
		return ObservableFactory.merge( map( f ) );
	}
	public function observeOn<T>(observable : IObservable<T>, scheduler : IScheduler) : Observable<T>
		return new ObserveOnThis(observable, scheduler);

	public function observeOn2<T>(observable : IObservable<T>, executor : Executor) : Observable<T>
		return new ObserveOn(observable, executor);

	public function subscribeOn<T>(observable : IObservable<T>, scheduler : IScheduler) : Observable<T>
		return new ObserveOnThis(observable, scheduler);
}
