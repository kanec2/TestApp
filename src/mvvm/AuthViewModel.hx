package mvvm;

class AuthViewModel {
	private var _authService:IAuthService;

	public ICommand loginCommand{get;}
	public ICommand registerCommand{get;}

	public function new(authService:IAuthService)
	{
		_authService = authService;
		loginCommand = new RelayCommand(Login);
		registerCommand = new RelayCommand(Register);
	}
	private function login()
	{
		_authService.login("username", "password").subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error: "+e);},
                (success)->
                {
                    if (success) {
                        trace("Login successful.");
                    } else {
                        trace("Login failed.");
                    }
                }
            )
        );
	}
	private function register()
	{
        _authService.register("username", "password").subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error: "+e);},
                (success)->
                {
                    if (success) {
                        trace("Login successful.");
                    } else {
                        trace("Login failed.");
                    }
                }
            )
        );
	}
}