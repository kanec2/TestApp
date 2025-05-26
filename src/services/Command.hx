package services;

class Command implements ICommand {
    var func:Void->Bool;
    public function new(func:Void->Bool) {
        this.func = func;
    }
    public function execute(){
        this.func();
    }
}