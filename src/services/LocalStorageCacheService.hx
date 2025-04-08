package services;

import hx.injection.Service;

class LocalStorageCacheService implements Service {
    private var filePath:String ;
    private var cache:Map<String, Dynamic>  = new Map<String, Dynamic>();

    public function new()
    {
        filePath = Path.Combine(Application.persistentDataPath, "cachedData.json");
        loadCacheFromFile();
    }

    // Cache methods
    public function setCache<T>(key:String, value:T):Void
    {
        cache.set(key,value);
        //cache[key] = value;
    }

    public function getCache<T>(key:String):T
    {
        if(cache.exists(key)){
            var value = cache.get(key);
            return cast(value);
        }
        return null; // Return default value if key does not exist in cache
    }

    public function isCached(key:String):Bool
    {
        return cache.exists(key);
    }

    // Save Cache to JSON
    public function saveCacheToJson():Void
    {
        var fileCache = cacheFolder.path.join(filePath).toFile();
        var writer = new json2object.JsonWriter<Map<String, Dynamic>>();
        var friendsArrayJson = writer.write(cache);
        fileCache.writeString(friendsArrayJson);

        //var json = Json. //JsonUtility.ToJson(new CacheDataWrapper { Cache = cache });
        //File.WriteAllText(filePath, json);
    }

    private function loadCacheFromFile():Void
    {
        if (File.Exists(filePath))
        {
            string json = File.ReadAllText(filePath);
            CacheDataWrapper wrapper = JsonUtility.FromJson<CacheDataWrapper>(json);
            cache = wrapper.Cache;
        }
    }

    // Clears cached data
    public function clearCache():Void
    {
        cache.Clear();
        File.Delete(filePath); // Remove the cached data file if needed
    }

    // Wrapper used for serializing dictionary
    /*[System.Serializable]
    private class CacheDataWrapper
    {
        public Dictionary<string, object> Cache = new Dictionary<string, object>();
    }*/
}