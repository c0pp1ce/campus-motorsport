import 'package:flutter/material.dart';

import 'package:campus_motorsport/controller/token_controller/token_event.dart';

/// Provides the [token] which is needed for any http request except login & register.
class TokenController extends ChangeNotifier {
  String? _token;

  TokenController();

  /// Handles incoming events.
  void add(TokenEvent event) {
    if(event is SetToken) {
      _token = event.token;
      return;
    }

    if(event is DeleteToken) {
      _token = null;
      return;
    }

  }

  String? get token => _token;
}