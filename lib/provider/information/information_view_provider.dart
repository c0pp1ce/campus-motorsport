import 'package:campus_motorsport/provider/base_provider.dart';

/// Handles the info pages (training grounds, clipboards, team structure).
class InformationViewProvider extends BaseProvider {

}

enum InformationPage {
  generalInfo,
}

extension InfoPageExtension on InformationPage {
  String get pageName {
    switch (this) {
      case InformationPage.generalInfo:
        return 'Allgemeine Informationen';
    }
  }
}