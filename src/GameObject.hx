import enums.Relation;
import haxe.ds.Vector;

@:tink class GameObject {
    @:property var model:IGameObjectModel = _;
    @:property var relation:Relation = _;
    @:property @:forward(representation3D) var view3D:Object3DView = _;
    @:property @:forward(representation2D) var view2D:Object2DView = @byDefault null;

}