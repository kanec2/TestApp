
class TestEntity{
    var view:h2d.Object;

    var mapData:Map<String,Dynamic> = new Map<String, Dynamic>();
    public function new(view:h2d.Object, currentX: Float = 0, currentY: Float = 0){
        this.view = view;
        view.x = currentX;
        view.y = currentY;
    }
    public function setData(key:String, value:Dynamic){
        this.mapData.set(key, value);
    }
    public function getAllData(){
        return mapData;
    }
    public function setX(x:Float){
        view.x = x;
    }
    public function setY(y:Float){
        view.y = y;
    }

    public function getX(){
        return view.x;
    }

    public function getY(){
        return view.y;
    }

    public function getView(){
        return view;
    }
    public function setView(view:h2d.Object){
        this.view = view;
    }
}