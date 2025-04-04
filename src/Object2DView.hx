using tink.CoreApi;

@:tink class Object2DView extends ObjectView {
    @:property(return cast(representation,h2d.Object), representation = param) var representation2D:h2d.Object; 
    public function new(object:h2d.Object){
        this.representation = object;
    }
}