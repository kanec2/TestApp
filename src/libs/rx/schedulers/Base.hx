package libs.rx.schedulers;
import libs.rx.disposables.ISubscription;
import libs.rx.Core;
interface Base {
    public function now():Float ;
    //绝对的
    public function schedule_absolute(due_time:Null<Float>, action:Void ->Void ):ISubscription;
}

