import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';

class UsersProvider extends BaseProvider {
  List<User>? _users;
  final CrudUser _crudUser = CrudUser();

  Future<List<User>> get users async {
    if (_users == null) {
      await reload();
    }
    return _users!;
  }

  void removeUser(User user) {
    if (_users?.remove(user) ?? false) {
      notify();
    }
  }

  Future<void> reload() async {
    _users = await _crudUser.getUsers() ?? [];
    notify();
  }
}
