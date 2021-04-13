import 'package:campus_motorsport/controller/token_controller/token_controller.dart';

abstract class RegistrationEvent {}

/// The controller will attempt to send a http request in order to check the code.
class RequestCodeCheck extends RegistrationEvent {}

/// The controller will attempt to send a http request to perform the registration.
class RequestRegistration extends RegistrationEvent {
  TokenController tokenController;

  RequestRegistration(this.tokenController);
}

/// The request wont be cancelled directly (because it is async) but a flag will be set, so that
/// the UI knows that it should not navigate to the home screen.
class RequestCancelRequest extends RegistrationEvent {}

/// Resets the controller.
class RequestReset extends RegistrationEvent {}

/*
* Following only events to change single data properties.
* The validation for user input has to happen on UI side.
* To delete a property add the corresponding event with a null value.
*/

class ChangeFirstname extends RegistrationEvent {
  String? firstname;

  ChangeFirstname(this.firstname);
}

class ChangeLastname extends RegistrationEvent {
  String? lastname;

  ChangeLastname(this.lastname);
}

class ChangeEmail extends RegistrationEvent {
  String? email;

  ChangeEmail(this.email);
}

class ChangePassword extends RegistrationEvent {
  String? password;

  ChangePassword(this.password);
}

class ChangeInvitationCode extends RegistrationEvent {
  String? code;

  ChangeInvitationCode(this.code);
}
