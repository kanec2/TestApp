using tink.CoreApi;

@:tink class Object3DView extends ObjectView {
    @:property(return cast(representation,h3d.scene.Object), representation = param) var representation3D:h3d.scene.Object; 
    public function new(object:h3d.scene.Object){
        this.representation = object;
    }
}