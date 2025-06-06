package mvvm;

import services.ICommand;
import services.RelayCommand;
import services.Command;
import services.AuthenticationService;
import libs.rx.Observer;
class AuthViewModel {
	private var _authService:AuthenticationService;

	public var loginCommand: ICommand;
	public var registerCommand: ICommand;

	public function new(authService:AuthenticationService)
	{
		_authService = authService;
        var observLogin:Observer<String> = Observer.create(
            ()->{},
            (e)->{trace("Error: "+e);},
            (success)->
            {
                if (success != null) {
                    trace("Login successful.");
                } else {
                    trace("Login failed.");
                }
            }
        );
        var observRegister:Observer<Bool> = Observer.create(
            ()->{},
            (e)->{trace("Error: "+e);},
            (success)->
            {
                if (success != null) {
                    trace("Login successful.");
                } else {
                    trace("Login failed.");
                }
            }
        );
		loginCommand = new Command(()->{
            _authService.signIn("test1@mail.com", "123").subscribe(observLogin);
            return true;
        });
		registerCommand = new Command(()->{
            _authService.register("username", "password").subscribe(observRegister);
            return true;
        });

	}
    /*
	private function login()
	{
		_authService.signIn("username", "password").subscribe(
            Observer.create(
                ()->{},
                (e)->{trace("Error: "+e);},
                (success)->
                {
                    if (success != null) {
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
                    if (success != null) {
                        trace("Login successful.");
                    } else {
                        trace("Login failed.");
                    }
                }
            )
        );
	}*/
}