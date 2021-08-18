import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';

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

  Future<void> setOnSiteState(bool value) async {
    if (user == null) {
      return;
    }
    final success = await CrudUser().updateField(
      uid: user!.uid,
      key: 'onSite',
      data: value,
    );
    if (success) {
      user!.onSite = value;
      notify();
    }
  }
}
