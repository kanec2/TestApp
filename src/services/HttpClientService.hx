package services;

import http.HttpClient;

abstract class IHttpClientService {
    abstract public function getClient():HttpClient;
}
class HttpCLientService extends IHttpClientService
{
    var _config : Config;
    public function new(configuration : Config) {
        this._config = configuration;
    }

    public function getClient(options?:{followRedirects?:Bool, retryCount?:Int, retryDelayMs?:Int}):HttpClient {
        var client = new HttpClient();
        var followRedirects:Bool = false;
        var retryCount:Int = 5;
        var retryDelayMs:Int = 0;
        if(options != null){
            if(options.followRedirects != null) followRedirects = options.followRedirects;
            if(options.retryCount != null) retryCount = options.retryCount;
            if(options.retryDelayMs != null) retryDelayMs = options.retryDelayMs;
        }
        client.followRedirects = followRedirects; 
        client.retryCount = retryCount;
        client.retryDelayMs = retryDelayMs;
        return client;
    }
}