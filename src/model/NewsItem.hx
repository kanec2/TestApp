package model;

typedef RootNewsData = {
    public var news:Array<NewsItem>;
}

typedef NewsItem  = { 
    public var title:String;
    public var content:String;
    public var publishedDate:Date; 
}