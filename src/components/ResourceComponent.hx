package components;

class ResourceComponent {
    public var resourceType:String;
    public var amount:Int;

    public function new(resourceType = "GOLD", amount = 0) {
        this.resourceType = resourceType;
        this.amount = amount;
    }
}