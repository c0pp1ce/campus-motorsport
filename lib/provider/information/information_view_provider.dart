import 'package:campus_motorsport/provider/base_provider.dart';

/// Handles the info pages (training grounds, clipboards, team structure).
class InformationViewProvider extends BaseProvider {
  InformationViewProvider({
    required this.toggle,
    this.offlineMode = false,
  });

  final void Function() toggle;
  final bool offlineMode;
  InformationPage currentPage = InformationPage.generalInfo;

  void switchTo(InformationPage page) {
    if (page != currentPage) {
      currentPage = page;
      toggle();
      notify();
    }
  }
}

enum InformationPage {
  generalInfo,
  clipboards,
  addClipboard,
}

extension InfoPageExtension on InformationPage {
  String get pageName {
    switch (this) {
      case InformationPage.generalInfo:
        return 'Allgemeine Informationen';
      case InformationPage.clipboards:
        return 'Clipboards';
      case InformationPage.addClipboard:
        return 'Clipboard erstellen';
    }
  }
}
