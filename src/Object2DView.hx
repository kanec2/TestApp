using tink.CoreApi;

@:tink class Object2DView extends ObjectView {
    public function set2DRepresentation(object:h2d.Object){
        representation = Left(object);
    }

    //@:calc inline var is2D = return switch representation { case  case Right(obj3d) : return false; default: return null; };
}