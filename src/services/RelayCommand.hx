
class RelayCommand<T> implements ICommand {
    private var func:T->Void;

    public function new(func:T->Void) {
        this.func = func;
    }

    public function execute(v:T):Void {
        func(v);
    }
}