class Util {
    public static function groupBy<T>(arr:Array<T>,func:T->String){
        var groupMap:Map<String,Array<T>> = new Map<String,Array<T>>();
        for(item in arr){
            var key = func(item);
            if(!groupMap.exists(key)){
                var arr:Array<T> = new Array<T>();
                groupMap.set(key,arr);
            }
            
        }
    }
}
