import 'package:flutter/cupertino.dart';

/// Parent class for the controllers.
abstract class BaseController extends ChangeNotifier {
  /// Used to display error messages that occurred during controller methods.
  String? errorMessage;
  /// Indicates if the controller is currently handling a http request.
  bool loading = false;
  /// Used to determine íf the main objective of the controller was a success.
  ///
  /// E.g. LoginController -> Successful login..
  bool success = false;
  bool isDisposed = false;

  void reset() {
    loading = false;
    success = false;
    errorMessage = null;
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  /// Dont call [notifyListeners] if controller has been disposed.
  void notify() {
    if(isDisposed) return;
    notifyListeners();
  }
}