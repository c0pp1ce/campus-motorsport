import 'package:campus_motorsport/provider/base_provider.dart';

/// Determines which sub page of home should be shown.
class HomeProvider extends BaseProvider {
  HomePage currentPage = HomePage.overview;

  void switchTo(HomePage page) {
    if(page != currentPage) {
      currentPage = page;
      notify();
    }
  }

}

enum HomePage {
  overview,
  attendanceList,
}