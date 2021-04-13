import 'package:campus_motorsport/controller/base_controller/base_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/controller/token_controller/token_event.dart';
import 'package:campus_motorsport/models/utility/response_data.dart';
import 'package:campus_motorsport/services/rest_services.dart';

/// Responsible for handling the registration process.
class RegistrationController extends BaseController {
  String? _firstname;
  String? _lastname;
  String? _email;
  String? _password;
  String? _invitationCode;
  TokenController? _tokenController;

  /// Shows if the invitation code check was successful.
  bool validCode = false;

  RegistrationController() : super();

  /// Entry point for calls from the UI.
  void add(RegistrationEvent event) {
    if (event is RequestCodeCheck) {
      _performCodeCheck();
      return;
    }

    if (event is RequestRegistration) {
      _performRegistration();
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

    if (event is ChangeInvitationCode) {
      _invitationCode = event.code;
      return;
    }
  }

  Future<void> _performCodeCheck() async {
    /// Wait for completion of the current request.
    if (loading) return;

    /// Reset controller status before new request.
    success = false;
    errorMessage = null;

    /// Check if the needed data is available.
    if (!_validateControllerData(false)) {
      return;
    }

    /// Request can be performed.
    loading = true;
    notifyListeners();
    Map<String, dynamic> data = _getControllerData(false);
    JsonResponseData responseData =
        await RestServices().postJson('/registration/invitation', data);

    /// On failure set status accordingly.
    if (responseData.statusCode != 200) {
      errorMessage = responseData.errorMessage;
      loading = false;
      success = false;
      notifyListeners();
      return;
    } else {
      /// Invitation code and email match.
      validCode = true;
      loading = false;
      notifyListeners();
      return;
    }
  }

  Future<void> _performRegistration() async {
    /// Wait for completion of the current request.
    if (loading) return;

    /// Reset controller status before new request.
    success = false;
    errorMessage = null;

    /// Check if the needed data is available.
    if (!_validateControllerData(true)) {
      return;
    }

    /// Request can be performed.
    loading = true;
    notifyListeners();
    Map<String, dynamic> data = _getControllerData(true);
    JsonResponseData responseData =
        await RestServices().postJson('/registration', data);

    /// On failure set status accordingly.
    if (responseData.statusCode != 201) {
      errorMessage = responseData.errorMessage;
      loading = false;
      success = false;
      notifyListeners();
      return;
    } else {
      /// On success hand over token to TokenProvider. Set status accordingly.
      String? token = responseData.data?['token'];
      if (token != null) {
        _tokenController!.add(SetToken(token));
        success = true;
        loading = false;
        errorMessage = null;
        notifyListeners();
        return;
      } else {
        /// If no token in response.
        errorMessage = 'Registrierung fehlgeschlagen.';
        loading = false;
        notifyListeners();
        return;
      }
    }
  }

  /// Notifies listeners about missing data.
  ///
  /// [forRegistration] determines which data to check (data for checking
  /// invitation or for performing registration).
  bool _validateControllerData(bool forRegistration) {
    if (_email == null) {
      errorMessage = "Email nicht gefunden.";
      notifyListeners();
      return false;
    }

    if (_invitationCode == null) {
      errorMessage = "Einladungscode nicht gefunden.";
      notifyListeners();
      return false;
    }

    /// Data for checking the code is complete.
    if (!forRegistration) {
      return true;
    }

    if (_tokenController == null) {
      errorMessage = "Token Controller nicht gefunden.";
      notifyListeners();
      return false;
    }

    if (_firstname == null) {
      errorMessage = "Vorname nicht gefunden.";
      notifyListeners();
      return false;
    }

    if (_lastname == null) {
      errorMessage = "Nachname nicht gefunden.";
      notifyListeners();
      return false;
    }

    if (_password == null) {
      errorMessage = "Passwort nicht gefunden.";
      notifyListeners();
      return false;
    }

    /// No missing data.
    return true;
  }

  /// Creates a map of the data.
  ///
  /// [forRegistration] determines what data to store in the map (for checking
  /// invitation or for performing registration).
  /// No null checks. Use [_validateControllerData] for that.
  Map<String, dynamic> _getControllerData(bool forRegistration) {
    Map<String, dynamic> data = Map();
    data["email"] = _email;
    data["code"] = _invitationCode;

    /// Data for checking the invitation complete.
    if (!forRegistration) {
      return data;
    }

    data["firstname"] = _firstname;
    data["lastname"] = _lastname;
    data["password"] = _password;
    return data;
  }

  /// Resets the controller.
  void reset() {
    super.reset();
    _firstname = null;
    _lastname = null;
    _email = null;
    _password = null;
    _invitationCode = null;
    _tokenController = null;
  }
}
