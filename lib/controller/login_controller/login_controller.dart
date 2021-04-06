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
      _errorMessage = 'Incomplete login data..';
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
    data['appid'] = 'Here should be the app id';

    /// Perform request.
    Map<String, dynamic> response = await RestServices.postJson('/login', data);

    /// On failure set status accordingly.
    if (response['statusCode'] != 200) {
      _errorMessage = response['decodedJson']['message'];
      _loading = false;
      notifyListeners();
      return;
    } else {
      /// On success hand over token to TokenProvider. Set status accordingly.
      String? token = response['decodedJson']['token'];
      if (token != null) {
        _tokenController!.add(SetToken(token));
        _success = true;
        _loading = false;
        _errorMessage = null;
        notifyListeners();
        return;
      } else {
        /// If no token in response.
        _errorMessage = 'No token in response.';
        _loading = false;
        notifyListeners();
        return;
      }
    }
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
