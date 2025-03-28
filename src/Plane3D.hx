import h3d.prim.UV;
import h3d.col.Point;
import h3d.prim.Polygon;

class Plane3D extends Polygon{
    public function new(size: Float) {
        var w = size/2*(250/224);
        var h = size/2;
        var p = [
			new Point(-w, h, 0),
			new Point(w, h, 0),
			new Point(w, -h, 0),
			new Point(-w, -h, 0)];
        var idx = new hxd.IndexBuffer();
        idx.push(0); idx.push(1); idx.push(3);
        idx.push(3); idx.push(1); idx.push(2);

        super(p, idx);
    }

    override public function addUVs(){
		unindex();
		uvs = [];

        uvs.push(new UV(0, 0)); uvs.push(new UV(1, 0)); uvs.push(new UV(0, 1));		
        uvs.push(new UV(0, 1)); uvs.push(new UV(1, 0)); uvs.push(new UV(1, 1));
    }
}