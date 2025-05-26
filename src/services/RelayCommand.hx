package services;
class ParametrizedCommand<T> implements ICommand {
    private var func:Array<T>->Void;
    private var params:Array<T>;

    public function setParameters(params:Array<T>){
        this.params = params;
        return this;
    }

    public function new(func:Array<T>->Void) {
        this.func = func;
    }

    public function execute():Void {
        func(this.params);
    }
}