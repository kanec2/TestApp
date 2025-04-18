package libs.rx;

import libs.rx.disposables.ISubscription;
import libs.rx.disposables.Boolean;
class Subscription {

    inline static public function empty() return create(function() {});

    inline static public function create(unsubscribe:Void -> Void) {
        // (* Wrap the unsubscribe function in a lazy value, to get idempotency. *)

        return new Boolean(unsubscribe);
    }

} 