import 'package:campus_motorsport/provider/base_provider.dart';

/// Determines which sub page of home should be shown.
class HomeProvider extends BaseProvider {
  HomeProvider({
    required this.toggle,
  }) : super();

  final void Function() toggle;
  HomePage currentPage = HomePage.overview;
  bool allowContextDrawer = false;

  void switchTo(HomePage page) {
    if (page != currentPage) {
      currentPage = page;
      toggle();
      notify();
    }
  }
}

enum HomePage {
  overview,
  attendanceList,
}

extension HomePageExtension on HomePage {
  String get pageName {
    switch (this) {
      case HomePage.overview:
        return 'Übersicht';
      case HomePage.attendanceList:
        return 'Anwesenheitsliste';
    }
  }
}
