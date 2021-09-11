import 'package:campus_motorsport/provider/base_provider.dart';

/// Determines which subpage of User Management should be shown.
class UserManagementProvider extends BaseProvider {
  UserManagementProvider({
    required this.toggle,
  }) : super();

  final void Function() toggle;
  UMPage currentPage = UMPage.acceptUsers;

  void switchTo(UMPage page) {
    if (page != currentPage) {
      currentPage = page;
      toggle();
      notify();
    }
  }
}

enum UMPage {
  acceptUsers,
  admins,
}

extension UMPageExtension on UMPage {
  String get pageName {
    switch (this) {
      case UMPage.acceptUsers:
        return 'User bestätigen';
      case UMPage.admins:
        return 'Administratoren';
    }
  }
}
