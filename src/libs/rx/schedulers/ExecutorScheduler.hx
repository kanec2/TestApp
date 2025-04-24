package libs.rx.schedulers;

import hx.concurrent.executor.Executor;
import haxe.ds.Either;
import libs.rx.disposables.ISubscription;
import hx.concurrent.executor.Schedule;
//import haxe.ds.Either2;
import haxe.exceptions.NotImplementedException;
import sys.thread.Thread;
//import sys.Timer; // for delay on some platforms, optional

class ExecutorScheduler implements IScheduler {
    var executor:Executor;
    var schedule:Schedule;

    public function new(executor:Executor, ?schedule:Schedule) {
        this.executor = executor;
        this.schedule = schedule != null ? schedule : Schedule.ONCE(0);
    }

    // Return current time in milliseconds
    public function now():Float {
        return Date.now().getTime();
    }

    // Schedule after relative delay (in ms)
	public function schedule_relative(delay:Null<Float>, action:() -> Void):ISubscription {
		var dueTime = delay != null ? delay : 0;
        var intDueTime:Int = cast(dueTime);
        var sch:Schedule = (dueTime > 0) ? Schedule.ONCE(intDueTime) : this.schedule;
        return schedule_action(action, sch);
	}

    // Schedule at absolute time (dueTime in ms since epoch)
    public function schedule_absolute(due_time:Null<Float>, action:() -> Void):ISubscription {
        if (due_time == null) {
            return schedule_action(action, this.schedule);
        }

        var now = this.now();
        var delay = Math.max(0, due_time - now);
        var intDelay:Int = cast(delay);
        var sch = Schedule.ONCE(intDelay);
        return schedule_action(action, sch);
	}

    // Recursive scheduling support
    public function schedule_recursive(action:(Void -> Void) -> Void):ISubscription {
        var isDisposed = false;

        var recursiveAction = null;

        recursiveAction = function() {
            if (isDisposed) return;
            action(function() {
                if (isDisposed) return;
                recursiveAction();
            });
        };

        return this.schedule_relative(0, recursiveAction);

	}

    // Schedule periodic action with initial delay and period in ms
    public function schedule_periodically(initial_delay:Null<Float>, period:Null<Float>, action:() -> Void):ISubscription {
        var delay = initial_delay != null ? initial_delay : 0;
        var per = period != null ? period : 0;
        var intPer:Int = cast(per);
        var intDelay:Int = cast(delay);
        var isDisposed = false;

        // Internal function to schedule next iteration
        function scheduleNext() {
            if (isDisposed) return;

            action();

            if (isDisposed) return;

            // Schedule next after period delay
            schedule_action(scheduleNext, Schedule.ONCE(intPer));
        }

        // Start chain
        return schedule_action(scheduleNext, Schedule.ONCE(intDelay));

	}
    private function schedule_action(action:() -> Void, sch:Schedule):ISubscription {
        
        // submit returns TaskFuture which supports cancellation/disposal,
        // implement ISubscription wrapping it
        var future = executor.submit(action, sch);
        
        return Subscription.create(() -> future.cancel());
    }
    
    /*
    public function schedule_periodically(initial_delay:Null<Float>, period:Null<Float>, action:() -> Void):ISubscription {

    }

    // Helper to submit tasks via executor.submit with schedule
    */









	
}