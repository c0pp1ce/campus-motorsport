import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/base_provider.dart';

/// Simple wrapper to provide info about the current user to the app.
class CurrentUser extends BaseProvider {
  User? _currentUser;

  /// Notifies listeners about changes to the user.
  set user(User? user) {
    _currentUser = user;
    notify();
  }

  User? get user {
    return _currentUser;
  }
}