package libs.rx.disposables;

import libs.rx.disposables.Assignable.RxAssignableState;
import libs.rx.disposables.Assignable.AssignableState;
import libs.rx.disposables.Assignable;
import libs.rx.disposables.Assignable;
import libs.rx.Subscription;

class SerialAssignment extends Assignable {

	public function new() {
		super();
	}

	static public function create() {
		return new SerialAssignment();
	}

	public function set( subscription : ISubscription ) {
		var old_state = AtomicData.update_if(
			function ( s : RxAssignableState ) return !s.is_unsubscribed,
			function ( s ) {
				AssignableState.set( s, subscription );
				return s;
			}, state );

		var __subscription = old_state.subscription;
		if ( __subscription != null ) __subscription.unsubscribe();

		__set( old_state, subscription );
	}
}
