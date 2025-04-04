import h3d.col.Point;
import h3d.Vector;

@:tink class BuildingGameObjectModel implements IGameObjectModel{
    @:property var health:Int = _;
    @:property var position:h3d.Vector = @byDefault new h3d.Vector(0,0,0);

    public function getData():Dynamic{
        return health;
    }
}