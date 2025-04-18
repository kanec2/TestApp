package libs.rx;
import libs.rx.Core.RxObserver;
import libs.rx.observers.ObserverBase;
import libs.rx.observers.CheckedObserver;
import libs.rx.observers.SynchronizedObserver;
import libs.rx.observers.AsyncLockObserver;
import libs.rx.observers.IObserver;

import libs.rx.schedulers.CurrentThread;
import libs.rx.schedulers.DiscardableAction;
import libs.rx.schedulers.Immediate;
import libs.rx.schedulers.NewThread;
import libs.rx.schedulers.MakeScheduler;
import libs.rx.schedulers.Test;
import libs.rx.schedulers.IScheduler;
import libs.rx.schedulers.TimedAction;
import libs.rx.Subscription;
import libs.rx.disposables.Composite;
class Scheduler {

    public static var currentThread:CurrentThread = new CurrentThread();
    public static var newThread:NewThread = new NewThread();
    public static var immediate:Immediate = new Immediate();
    public static var test:Test = new Test();
    public static var timeBasedOperations(get, set):IScheduler;
    static var __timeBasedOperations:IScheduler;

    static function get_timeBasedOperations() {
        if (__timeBasedOperations == null){
         
                __timeBasedOperations = Scheduler.currentThread;

        }

        return __timeBasedOperations ;
    }

    static function set_timeBasedOperations(x) {
        return __timeBasedOperations = x;
    }

}