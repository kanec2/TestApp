package services;
import extensions.Auth;

class AuthenticationService {
    var auth:Auth;
    var eventService:AppEventService;
    public function new(config : AppConfig, eventService:AppEventService) {
        this.auth = new Auth("localhost", 2567);
        this.eventService = eventService;
    }

    public function register(email,pass){
        trace("try to register");

        var token:String = "";
        var userData:Dynamic = null;
        this.auth.registerWithEmailAndPassword("wtf22@mail.com", "123", (regErr, regData) ->{
            if(regErr!=null){
                eventService.dispatch({ event: AppEvent.REGISTER_FAIL, data: regErr.message });
            }
            if(regData != null){
                token = regData.token;
                userData = regData.user;
                eventService.dispatch({ event: AppEvent.REGISTER_SUCCESS, data: token });
            }
        });
    }

    public function signIn(email,pass){
        trace("try to login");
        
        this.auth.signInWithEmailAndPassword("wtf22@mail.com", "123", (err, data) ->{
            trace("Auth?");
            if(err != null){
                eventService.dispatch({ event: AppEvent.LOGIN_FAIL, data: err.message });
            }
            if(data != null){
                trace(data);
                eventService.dispatch({ event: AppEvent.LOGIN_SUCCESS, data: data.token });
            }
        });
    }
}