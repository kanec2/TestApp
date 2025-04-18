package services;
import hx.injection.Service;
using libs.rx.Observable;
abstract class IFriendService implements Service{
    abstract public function getFriends():Observable<Array<api.models.JsonModels.FriendsData>>;
}