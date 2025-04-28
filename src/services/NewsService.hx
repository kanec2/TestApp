package services;

abstract class INewsService 
{ 
    abstract public function getLatestNews():Observable<Array<NewsItem>>; 
} 

class NewsService extends INewsService 
{ 
    private var _httpClient:IHttpClientService; 
    public function new(httpClient:IHttpClientService) 
    { 
        _httpClient = httpClient; 
    } 
    public function getLatestNews() : Observable<Array<NewsItem>> 
    { 
        return Observable.create(_observer -> {
            _httpClient.getClient().get(_config.usersGetUrl, [], []).then(response -> {
                _observer.on_next(response.bodyAsJson);
                _observer.on_completed();
            }, (error:HttpError) -> {
                _observer.on_error(error.bodyAsString);
            });
            return Subscription.empty();
        }).map((rawJson) ->{
            var json:RootNewsData = Json.parse(rawJson);
            return json.news;
        });
    }
}