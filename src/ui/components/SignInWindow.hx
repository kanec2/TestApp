package ui.components;

import haxe.ui.notifications.NotificationType;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.containers.dialogs.CollapsibleDialog;
import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.events.MouseEvent;

using haxe.ui.animation.AnimationTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/views/sign-in-window.xml"))
class SignInWindow extends Dialog {
    public var validationResult:Bool = false;
    public function new() {
        super();
        buttons = DialogButton.CANCEL | "Login";
        defaultButton = "Login";
    }
    
    public override function validateDialog(button:DialogButton, fn:Bool->Void) {
        var valid = true;
        if (button == "Login") {
            if (username.text == "" || username.text == null) {
                username.flash();
                valid = false;
            } 
            if (password.text == "" || password.text == null) {
                password.flash();
                valid = false;
            }

            if (valid == false) {
                NotificationManager.instance.addNotification({
                    title: "Problem Logging In",
                    body: "There was a problem attempting to login, please try again.",
                    type: NotificationType.Error
                });
                this.shake();
            } else {
                NotificationManager.instance.addNotification({
                    title: "Log In Successful",
                    body: "Login successful! Welcome " + username.text + "!",
                    type: NotificationType.Success
                });
            }
        }
        validationResult = valid;
        fn(valid);
    }
}