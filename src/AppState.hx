import libs.rx.subjects.BehaviorSubject;
import model.NewsItem;
import model.Friend;
import model.Lobby;

class AppState {
    public var currentUser(get,null):BehaviorSubject<User> = new BehaviorSubject<User>(null);
    public var newsFeed(get,null): BehaviorSubject<Array<NewsItem>> = new BehaviorSubject<Array<NewsItem>>(new Array<NewsItem>()); 
    public var friendsList(get,null): BehaviorSubject<Array<Friend>> = new BehaviorSubject<Array<Friend>>(new Array<Friend>()); 
    public var activeLobbies(get,null): BehaviorSubject<Array<Lobby>> = new BehaviorSubject<List<Lobby>>(new Array<Lobby>()); 
}