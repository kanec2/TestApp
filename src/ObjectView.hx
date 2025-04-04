using tink.CoreApi;

@:tink abstract class ObjectView implements IObjectView{
    
    @:calculated var is2d = switch representation {
        case (c : h2d.Object) : true;
        case (e : h3d.scene.Object): false;
        default : null;
    }
    @:calculated var is3d = switch representation {
        case (c : h3d.scene.Object): true;
        case (e : h2d.Object) : false;
        default : null;
    }

}