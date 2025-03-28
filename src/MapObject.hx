using tink.CoreApi;

@:tink class MapObject {
    @:property @:forward(scale,getAbsPos,x,y,z,cullingCollider,scaleX,scaleY,scaleZ,material) var m : h3d.scene.Mesh = _;
    @:property var pos      : Float             = _;
    @:property var cx       : Float             = _;
    @:property var cy       : Float             = _;
    @:property var ray      : Float             = _;
    @:property var speed    : Float             = _;
}