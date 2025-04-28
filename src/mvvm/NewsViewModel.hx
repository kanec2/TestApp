package mvvm;

class NewsViewModel {
	private var _newsSubject: BehaviorSubject<Array<NewsItem>>;
	
	public var news(get,never) : Observable<Array<NewsItem>>;


	public function new(newsService:INewsService)
	{
		_newsSubject = new BehaviorSubject<Array<NewsItem>>(new Array<NewsItem>());
		loadNews();
	}
	private function loadNews()
	{
		newsService.getLatestNews().subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error: "+e);},
                (news)->{_newsSubject.on_next(news);}
            )
        );
	}
}
