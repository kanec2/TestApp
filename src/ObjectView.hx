using tink.CoreApi;

@:tink abstract class ObjectView implements IObjectView{
    var representation:Representation;
    @:calculated var is2d = switch representation {
        case h2d.Object(c): true;
        case h3d.scene.Object(e): false;
        null;
    }
    @:calculated var is3d = switch representation {
        case h3d.scene.Object(c): true;
        case h2d.Object(e) : false;
        null;
    }
}