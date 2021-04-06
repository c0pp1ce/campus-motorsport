import 'package:campus_motorsport/controller/token_controller/token_controller.dart';

/// Parent class for the events processed by the login controller.
abstract class LoginEvent {}


class SaveEmail extends LoginEvent {
  String? email;

  SaveEmail(this.email);
}


class SavePassword extends LoginEvent {
  String? password;

  SavePassword(this.password);
}


/// Add this event to the controller to perform the login.
class RequestLogin extends LoginEvent {
  /// The controller which will save the token if login is successful.
  TokenController tokenController;

  RequestLogin(this.tokenController);
}


/// Request the reset of the controller status.
class RequestReset extends LoginEvent {}
