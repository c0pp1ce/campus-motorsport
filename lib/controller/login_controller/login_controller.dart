import 'package:campus_motorsport/controller/base_controller/base_controller.dart';
import 'package:campus_motorsport/infrastructure/auth/cm_auth.dart';

import 'package:campus_motorsport/controller/login_controller/login_event.dart';
import 'package:campus_motorsport/models/user/user.dart';

/// Responsible for handling the login process.
class LoginController extends BaseController {
  final CMAuth _auth;
  String? _email;
  String? _password;

  LoginController()
      : _auth = CMAuth(),
        super();

  /// Entry point for calls from the UI.
  void add(LoginEvent event) {
    if (event is ChangeEmail) {
      _email = event.email?.trim().toLowerCase();
      return;
    }

    if (event is ChangePassword) {
      _password = event.password;
      return;
    }

    if (event is RequestLogin) {
      tokenController = event.tokenController;
      _firebaseLogin();
      return;
    }

    if (event is RequestCancelLogin) {
      cancelRequest = true;
      return;
    }

    if (event is RequestReset) {
      reset();
      return;
    }
  }

  /// Firebase login.
  Future<void> _firebaseLogin() async {
    setStatusPreRequest();
    if (_email != null && _password != null) {
      /// Try login if data is complete.
      User? user =
          await _auth.login(email: _email!, password: _password!);

      if (user != null) {
        /// If login was a success.
        if(!user.emailVerified) {
          requestFailure("Email muss bestätigt werden.");
          return;
        } else {
          // TODO : Check if user has been accepted.
          requestSuccess(mainObjective: true);
        }
      } else {
        requestFailure("Login fehlgeschlagen");
      }
    }
  }

  /// Resets the controller.
  void reset() {
    super.reset();
    _email = null;
    _password = null;
  }
}
