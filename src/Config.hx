@:tink final class Config {
    @:forward(friendCache,cachePath,imageMappingPath,imageCachePath,serverAddress,serverPort,usersGetUrl,addFriendsUrl) public var  appConfig           : ApplicationConfig;
    /*public var friendCache         : String;
    public var imageMappingPath    : String;
    public var imageCachePath      : String;
    public var serverAddress       : String;
    public var serverPort          : Int;
    public var usersGetUrl         : String;*/
    public function new() { }
}