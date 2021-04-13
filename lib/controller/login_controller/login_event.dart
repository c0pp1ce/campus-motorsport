import 'package:campus_motorsport/controller/token_controller/token_controller.dart';

/// Parent class for the events processed by the login controller.
abstract class LoginEvent {}

/// Add this event to the controller to perform the login.
class RequestLogin extends LoginEvent {
  /// The controller which will save the token if login is successful.
  TokenController tokenController;

  RequestLogin(this.tokenController);
}

/// The request wont be cancelled directly (because it is async) but a flag will be set, so that
/// the UI knows that it should not navigate to the home screen.
class RequestCancelLogin extends LoginEvent {}

/// Request the reset of the controller status.
class RequestReset extends LoginEvent {}

/*
* Following only events to change single data properties.
* The validation for user input has to happen on UI side.
* To delete a property add the corresponding event with a null value.
*/

class ChangeEmail extends LoginEvent {
  String? email;

  ChangeEmail(this.email);
}

class ChangePassword extends LoginEvent {
  String? password;

  ChangePassword(this.password);
}
