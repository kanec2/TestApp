using tink.CoreApi;
typedef Representation = Union<h2d.Object, h3d.scene.Object>;//Either<h2d.Object, h3d.scene.Object>;

interface IObjectView{
    var representation:Representation;
}