package libs.rx.disposables;
import libs.rx.disposables.Assignable.RxAssignableState;
import libs.rx.disposables.Assignable.AssignableState;
import libs.rx.disposables.Assignable;
import libs.rx.disposables.Assignable;
import libs.rx.Subscription;
class SingleAssignment extends Assignable {
    public function new() {
        super();
    }

    static public function create() {
        return new SingleAssignment();
    }

    public function set(subscription:ISubscription) {
        var old_state = AtomicData.update_if(
            function(s:RxAssignableState) return !s.is_unsubscribed,
            function(s) {
                if (s.subscription == null)
                    AssignableState.set(s, subscription);
                else
                    throw "SingleAssignment";
                return s;
            }, state);

        __set(old_state, subscription);
    }
} 