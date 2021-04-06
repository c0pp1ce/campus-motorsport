import 'package:campus_motorsport/controller/token_controller/token_event.dart';
import 'package:campus_motorsport/services/rest_services.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';

/// Responsible for handling the login process.
///
/// Event-based.
/// [errorMessage] is != null, if an error in the http request occurred.
class LoginController extends ChangeNotifier {
  String? _email;
  String? _password;

  TokenController? _tokenController;

  String? _errorMessage;
  bool _loading = false;
  bool _success = false;

  LoginController();

  /// Handles incoming events.
  void add(LoginEvent event) {
    if (event is SaveEmail) {
      _email = event.email?.trim().toLowerCase();
      return;
    }

    if (event is SavePassword) {
      _password = event.password;
      return;
    }

    if (event is RequestLogin) {
      _tokenController = event.tokenController;
      _login();
      return;
    }

    if (event is RequestReset) {
      _reset();
      return;
    }
  }

  /// Performs the http request and processes the answer.
  Future<void> _login() async {
    /// Wait for the current request to finish before sending another.
    if (_loading) return;

    /// Avoid request with incomplete data.
    if (_email == null || _password == null) {
      _errorMessage = 'Login Daten unvollständig.';
      _success = false;
      notifyListeners();
      return;
    }

    /// Set controller status.
    _success = false;
    _errorMessage = null;
    _loading = true;
    notifyListeners();

    /// Create map for json encoding.
    Map<String, String> data = new Map();
    data['email'] = _email!;
    data['password'] = _password!;
    //data['appid'] = 'Here should be the app id';

    /// Perform request.
    Map<String, dynamic> response = await RestServices.postJson('/login', data);

    /// On failure set status accordingly.
    if (response['statusCode'] != 200) {
      if (response["decodedJson"] == null) {
        /// Failure and no response body.
        _errorMessage = "Keine Server Antwort.";
      } else if (response["statusCode"] == 422) {
        /// Validation errors.
        _errorMessage = _handleValidationError(response);
      } else {
        /// Other errors.
        _errorMessage = response['decodedJson']['detail'];
      }
      _loading = false;
      notifyListeners();
      return;
    } else {
      /// On success hand over token to TokenProvider. Set status accordingly.
      String? token = response['decodedJson']?['token'];
      if (token != null) {
        _tokenController!.add(SetToken(token));
        _success = true;
        _loading = false;
        _errorMessage = null;
        notifyListeners();
        return;
      } else {
        /// If no token in response.
        _errorMessage = 'Login fehlgeschlagen.';
        _loading = false;
        notifyListeners();
        return;
      }
    }
  }

  /// Format the error string if validation error occurred.
  String? _handleValidationError(Map<String, dynamic> response) {
    var errorList = response["decodedJson"]["detail"] as List<dynamic>;
    String? error;

    /// Multiple errors possible.
    for (int i = 0; i < errorList.length; i++) {
      error =
          (error ?? '') + errorList[i]["loc"][1] + ' ' + errorList[i]["msg"];
      if (i != errorList.length - 1) error = error + "\n";
    }
    return error;
  }

  /// Resets the controller.
  void _reset() {
    _email = null;
    _password = null;
    _tokenController = null;
    _loading = false;
    _success = false;
    _errorMessage = null;
  }

  String? get errorMessage => _errorMessage;

  bool get loading => _loading;

  bool get success => _success;
}
