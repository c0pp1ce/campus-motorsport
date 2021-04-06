import 'package:email_validator/email_validator.dart';

/// This class provides different methods to validate user input.
///
/// The validators return null if the validation passes, and a String if validation fails.
class ValidationServices {
  static final int passwordLength = 6;

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
    String? valueEmptyError = validateNotEmpty(value, 'Email');
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
    String? valueEmptyError = validateNotEmpty(value, 'Passwort');
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
}
