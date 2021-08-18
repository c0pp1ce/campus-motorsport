import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/provider/base_provider.dart';

/// Handles the info pages (training grounds, clipboards, team structure).
class InformationViewProvider extends BaseProvider {
  InformationViewProvider({
    required this.toggle,
    this.offlineMode = false,
  }) {
    _allowedCategories = [];
    _addAllCategories();
  }

  late List<CpTypes> _allowedCategories;
  List<CpTypes> get allowedCategories => _allowedCategories;
  final void Function() toggle;
  final bool offlineMode;

  /// Initial page.
  InformationPage currentPage = InformationPage.generalInfo;
  bool allowContextDrawer = false;

  void switchTo(InformationPage page) {
    if (page != currentPage) {
      currentPage = page;
      if (page == InformationPage.clipboards) {
        allowContextDrawer = true;
      } else {
        allowContextDrawer = false;
      }
      toggle();
      notify();
    }
  }

  void allowCategory(CpTypes c) {
    if (!_allowedCategories.contains(c)) {
      _allowedCategories.add(c);
      notify();
    }
  }

  void hideCategory(CpTypes c) {
    if (_allowedCategories.remove(c)) {
      notify();
    }
  }

  void resetAllowedCategories([bool notifyListeners = true]) {
    _allowedCategories.clear();
    _addAllCategories();
    if (notifyListeners) {
      notify();
    }
  }

  void _addAllCategories() {
    CpTypes.values.forEach(_allowedCategories.add);
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
