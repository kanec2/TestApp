package services;

abstract class IAuthService 
{ 
    abstract public function login(username:String, password:String):IObservable<Bool>;
    abstract public function rogin(username:String, password:String):IObservable<Bool>;

} 
class AuthService extends IAuthService {
	private var _httpClient:IHttpClientService;

	public function new(httpClient: IHttpClientService)
	{
		_httpClient = httpClient;
	}
	public function login(username:String, password:String):Observable<Bool>
	{
		return Observable.FromAsync(async() => {
			var response = await
			_httpClient.PostAsJsonAsync("https://api.example.com/auth/login", new {
				username,
				password
			});
			return response.IsSuccessStatusCode;
		});
	}
	public IObservable<bool>
	Register(string username, string password)
	{
		return Observable.FromAsync(async() => {
			var response = await
			_httpClient.PostAsJsonAsync("https://api.example.com/auth/register", new {
				username,
				password
			});
			return response.IsSuccessStatusCode;
		});
	}
}