package services;

import hx.injection.Service;

class LocalStorageService implements Service{

    private var filePath:String;

    public function new(config : AppConfig, eventService:AppEventService) {
        filePath = Path.Combine(Application.persistentDataPath, "savefile.json");
        this.auth = new Auth("localhost", 2567);
        this.asyncDispatcher = eventService.asyncDispatcher;
    }
    // PlayerPrefs Methods
    public function savePlayerScore(score:Int):Void
    {
        PlayerPrefs.SetInt("PlayerScore", score);
        PlayerPrefs.Save();
    }

    public function loadPlayerScore():Int
    {
        return PlayerPrefs.GetInt("PlayerScore", 0); // Default value is 0
    }

    public function SavePlayerName(name:String):Void
    {
        PlayerPrefs.SetString("PlayerName", name);
        PlayerPrefs.Save();
    }

    public function loadPlayerName():String
    {
        return PlayerPrefs.GetString("PlayerName", "DefaultName"); // Default value
    }

    // JSON Serialization Methods
    public function saveDataAsJson(data:GameData):Void
    {
        string json = JsonUtility.ToJson(data);
        File.WriteAllText(filePath, json);
    }

    public function loadDataFromJson():GameData
    {
        if (File.Exists(filePath))
        {
            string json = File.ReadAllText(filePath);
            return JsonUtility.FromJson<GameData>(json);
        }
        return null;
    }

    // Binary Serialization Methods
    public function saveDataAsBinary(data:GameData):Void
    {
        BinaryFormatter formatter = new BinaryFormatter();

        using (FileStream stream = new FileStream(filePath, FileMode.Create))
        {
            formatter.Serialize(stream, data);
        }
    }

    public function loadDataFromBinary():GameData
    {
        if (File.Exists(filePath))
        {
            BinaryFormatter formatter = new BinaryFormatter();

            using (FileStream stream = new FileStream(filePath, FileMode.Open))
            {
                return formatter.Deserialize(stream) as GameData;
            }
        }
        return null;
    }
}

class GameData
{
    public int PlayerScore;
    public string PlayerName;
}