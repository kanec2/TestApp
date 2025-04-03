import enums.Relation;
import haxe.ds.Vector;

abstract class GameObject {
    public var model:IGameObjectModel;
    public var relation:Relation;
    var representation3D:IObjectView;
    var representation2D:IObjectView;

    public function new() {

    }

}