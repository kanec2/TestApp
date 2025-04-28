class FriendsViewModel {
	private var _friendsSubject:BehaviorSubject<Array<api.models.JsonModels.FriendsData>>

	public var friends(get,never):Observable<Array<api.models.JsonModels.FriendsData>>;

	public addFriendCommand:ICommand;
	public function new(friendsService:IFriendsService)
	{
		_friendsSubject = new BehaviorSubject<Array<api.models.JsonModels.FriendsData>>(new Array<api.models.JsonModels.FriendsData>());
		addFriendCommand = new RelayCommand<String>(AddFriend);
		loadFriends();
	}
	private function loadFriends()
	{
		friendsService.getFriends().subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error loading friends: "+e);},
                (friends)-> {_friendsSubject.on_next(friends) }
            )
        );
	}

	private function addFriend(username:String)
	{
		friendsService.addFriend(username).subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error: "+e);},
                (success)->
                {
                    if (success) {
                        trace("Friend added successfully.");
                        loadFriends();
                    } else {
                        trace("Failed to add friend.");
                    }
                }
            )
        );
	}
}