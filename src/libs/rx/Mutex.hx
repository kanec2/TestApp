package libs.rx;
#if cpp
    typedef Mutex=cpp.vm.Mutex;
#elseif hl
	typedef Mutex = sys.thread.Mutex;
#else

class Mutex {

    public function new() {

    }

    public function acquire() {
    }

    public function tryAcquire():Bool {
        return true;
    }

    public function release() {
    }
}
#end