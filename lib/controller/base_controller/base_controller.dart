import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
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

  /// Indicates if the current request should be canceled.
  /// Mainly used to avoid unwanted navigation.
  bool cancelRequest = false;

  /// Indicates if this controller has been disposed.
  bool isDisposed = false;

  /// Needed for any request.
  TokenController? tokenController;

  /// Checks if a token is available.
  /// Notifies listeners.
  bool checkToken() {
    if(tokenController?.token != null) {
      return true;
    } else {
      success = false;
      loading = false;
      errorMessage = "Token fehlt.";
      notify();
      return false;
    }
  }

  /// Resets the status before performing a fresh request.
  /// Notifies listeners.
  void setStatusPreRequest() {
    /// Set controller status.
    success = false;
    errorMessage = null;
    loading = true;
    cancelRequest = false;
    notify();
  }

  /// Sets the controller status to an error state.
  /// Notifies listeners.
  void requestFailure(String? error) {
    errorMessage = error;
    loading = false;
    success = false;
    notify();
    return;
  }

  /// Sets the controller status to a success state.
  /// Notifies listeners.
  /// [mainObjective] : Indicates if [success] should be set to true.
  void requestSuccess({bool mainObjective = true}) {
    if(mainObjective) {
      success = true;
    }
    loading = false;
    errorMessage = null;
    notify();
  }

  void reset() {
    loading = false;
    success = false;
    errorMessage = null;
    tokenController = null;
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