import 'package:campus_motorsport/controller/base_controller/base_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/infrastructure/auth/cm_auth.dart';
import 'package:campus_motorsport/models/user/user.dart';

/// Responsible for handling the registration process.
class RegistrationController extends BaseController {
  final CMAuth _auth;
  String? _firstname;
  String? _lastname;
  String? _email;
  String? _password;

  /// Shows if the invitation code check was successful.
  bool validCode = false;

  RegistrationController()
      : _auth = CMAuth(),
        super();

  /// Entry point for calls from the UI.
  void add(RegistrationEvent event) {
    if (event is RequestRegistration) {
      tokenController = event.tokenController;
      _firebaseSignUp();
      return;
    }

    if (event is RequestCancelRequest) {
      cancelRequest = true;
      return;
    }

    if (event is RequestReset) {
      reset();
      return;
    }

    if (event is ChangeFirstname) {
      _firstname = event.firstname?.trim();
      return;
    }

    if (event is ChangeLastname) {
      _lastname = event.lastname?.trim();
      return;
    }

    if (event is ChangeEmail) {
      _email = event.email?.trim();
      return;
    }

    if (event is ChangePassword) {
      _password = event.password;
      return;
    }
  }

  Future<void> _firebaseSignUp() async {
    setStatusPreRequest();
    if (!_validateControllerData()) {
      return;
    }

    User? user = await _auth.register(
        email: _email!,
        password: _password!,
        firstname: _firstname!,
        lastname: _lastname!);

    if (user != null) {
      /// If login was a success.
      /// TODO : Push firstname, lastname.
      ///
      requestSuccess(mainObjective: true);
    } else {
      requestFailure("Registrierung fehlgeschlagen");
    }
  }

  /// Notifies listeners about missing data.
  ///
  /// [forRegistration] determines which data to check (data for checking
  /// invitation or for performing registration).
  bool _validateControllerData() {
    /// Needed to store the token.
    if (tokenController == null) {
      errorMessage = "Token Controller nicht gefunden.";
      notify();
      return false;
    }

    if (_firstname == null) {
      errorMessage = "Vorname nicht gefunden.";
      notify();
      return false;
    }

    if (_lastname == null) {
      errorMessage = "Nachname nicht gefunden.";
      notify();
      return false;
    }

    if (_password == null) {
      errorMessage = "Passwort nicht gefunden.";
      notify();
      return false;
    }

    /// No missing data.
    return true;
  }

  /// Creates a map of the data.
  ///
  /// No null checks. Use [_validateControllerData] for that.
  Map<String, dynamic> _getControllerData() {
    Map<String, dynamic> data = Map();
    data["firstname"] = _firstname;
    data["lastname"] = _lastname;
    return data;
  }

  /// Resets the controller.
  void reset() {
    super.reset();
    _firstname = null;
    _lastname = null;
    _email = null;
    _password = null;
  }

  String? get email => _email;
}
