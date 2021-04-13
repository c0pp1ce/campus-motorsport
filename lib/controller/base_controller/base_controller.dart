import 'package:flutter/cupertino.dart';

/// Parent class for the controllers.
abstract class BaseController extends ChangeNotifier {
  /// Used to display error messages that occurred during controller methods.
  String? errorMessage;
  /// Indicates if the controller is currently handling a http request.
  bool loading = false;
  /// Used to determine íf the main objective of the controller was a success.
  ///
  /// Login -> Successful login etc.
  bool success = false;

  void reset() {
    loading = false;
    success = false;
    errorMessage = null;
  }
}