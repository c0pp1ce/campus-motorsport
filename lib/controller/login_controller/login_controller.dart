import 'package:campus_motorsport/controller/base_controller/base_controller.dart';
import 'package:campus_motorsport/controller/token_controller/token_event.dart';
import 'package:campus_motorsport/models/utility/response_data.dart';
import 'package:campus_motorsport/services/rest_services.dart';

import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';

/// Responsible for handling the login process.
class LoginController extends BaseController {
  String? _email;
  String? _password;

  TokenController? _tokenController;

  LoginController() : super();

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
      _tokenController = event.tokenController;
      _login();
      return;
    }

    if (event is RequestReset) {
      reset();
      return;
    }
  }

  /// Performs the http request and processes the answer.
  Future<void> _login() async {
    /// Wait for the current request to finish before sending another.
    if (loading) return;

    /// Avoid request with incomplete data.
    if (_email == null || _password == null) {
      errorMessage = 'Login Daten unvollständig.';
      success = false;
      notifyListeners();
      return;
    }

    /// tokenController needed to store the token.
    if(_tokenController == null) {
      errorMessage = 'TokenController nicht gefunden.';
      success = false;
      notifyListeners();
    }

    /// Set controller status.
    success = false;
    errorMessage = null;
    loading = true;
    notifyListeners();

    /// Create map for json encoding.
    Map<String, String> data = new Map();
    data['email'] = _email!;
    data['password'] = _password!;
    //data['appid'] = 'Here should be the app id';

    /// Perform request.
    JsonResponseData responseData = await RestServices().postJson('/login', data);

    /// On failure set status accordingly.
    if (responseData.statusCode != 200) {
      errorMessage = responseData.errorMessage;
      loading = false;
      success = false;
      notifyListeners();
      return;
    } else {
      /// On success hand over token to TokenProvider. Set status accordingly.
      String? token = responseData.data?['token'];
      if (token != null) {
        _tokenController!.add(SetToken(token));
        success = true;
        loading = false;
        errorMessage = null;
        notifyListeners();
        return;
      } else {
        /// If no token in response.
        errorMessage = 'Login fehlgeschlagen.';
        loading = false;
        notifyListeners();
        return;
      }
    }
  }

  /// Resets the controller.
  void reset() {
    super.reset();
    _email = null;
    _password = null;
    _tokenController = null;
  }
}
