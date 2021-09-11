import 'package:email_validator/email_validator.dart';

/// This class provides different methods to validate user input.
///
/// The validators return null if the validation passes, and a String if validation fails.
class Validators {
  static const int passwordLength = 6;
  static const int invitationCodeLength = 6;

  /// Returns null if [value] is != null and not an empty String.
  ///
  /// [inputDescription] is used to build an error message.
  String? validateNotEmpty(String? value, String inputDescription) {
    if (value?.isEmpty ?? true) {
      return '$inputDescription ist erforderlich.';
    } else {
      return null;
    }
  }

  /// Returns null if [value] is a valid email.
  String? validateEmail(String? value) {
    final String? valueEmptyError = validateNotEmpty(value, 'Email');
    if (valueEmptyError != null) {
      return valueEmptyError;
    }

    /// No need to check for value == null as this is caught by validateNotEmpty.
    if (EmailValidator.validate(value!)) {
      return null;
    } else {
      return 'Email ist ungültig.';
    }
  }

  /// Returns null if [value] is a valid password.
  String? validatePassword(String? value) {
    final String? valueEmptyError = validateNotEmpty(value, 'Passwort');
    if (valueEmptyError != null) {
      return valueEmptyError;
    }

    /// No need to check for value == null as this is caught by validateNotEmpty.
    if (value!.length >= passwordLength) {
      return null;
    } else {
      return 'Passwort muss min. $passwordLength Zeichen lang sein.';
    }
  }

  String? validateIntValue(
    String? value, [
    bool alsoValidateNotEmpty = false,
    bool alsoValidateGreaterZero = true,
  ]) {
    if (alsoValidateNotEmpty) {
      final String? valueEmptyError = validateNotEmpty(value, 'Wert');
      if (valueEmptyError != null) {
        return valueEmptyError;
      }
    } else {
      if (value?.isEmpty ?? true) {
        return null;
      }
    }

    if (int.tryParse(value!) == null) {
      return 'Nur natürliche Zahlen zulässig.';
    } else {
      if (int.tryParse(value)! < 1 && alsoValidateGreaterZero) {
        return 'Wert muss größer als 0 sein.';
      } else {
        return null;
      }
    }
  }

  // TODO : Remove if not needed anymore.
  /// Returns null if [value] is a valid invitation code.
  String? validateInvitationCode(String? value) {
    final String? valueEmptyError = validateNotEmpty(value, 'Einladungscode');
    if (valueEmptyError != null) {
      return valueEmptyError;
    }

    if (value!.length < 6) {
      return 'Der Code ist zu kurz.';
    }

    if (value.length > 6) {
      return 'Der Code ist zu lang';
    }

    if (value.trim().isEmpty) {
      return 'Nur Leerzeichen enthalten.\nIns Feld tippen und Eingabe löschen.';
    }

    final RegExp regExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regExp.hasMatch(value)) {
      return 'Code darf keine Sonderzeichen enthalten.';
    }

    return null;
  }
}
