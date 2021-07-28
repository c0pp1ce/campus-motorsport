import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/base_provider.dart';

/// Determines which subpage of User Management should be shown.
class ComponentsViewProvider extends BaseProvider {
  ComponentsViewProvider() {
    _allowedCategories = [];
    _addAllCategories();
  }
  ComponentsPage currentPage = ComponentsPage.allComponents;
  bool allowContextDrawer = true;

  /// Used to filter components list.
  late List<ComponentCategories> _allowedCategories;

  void switchTo(ComponentsPage page) {
    if (page != currentPage) {
      currentPage = page;
      if (currentPage == ComponentsPage.allComponents) {
        allowContextDrawer = true;
      } else {
        allowContextDrawer = false;
      }
      notify();
    }
  }

  void allowCategory(ComponentCategories c) {
    if (!_allowedCategories.contains(c)) {
      _allowedCategories.add(c);
      notify();
    }
  }

  void hideCategory(ComponentCategories c) {
    if (_allowedCategories.remove(c)) {
      notify();
    }
  }

  void resetAllowedCategories() {
    _allowedCategories.clear();
    _addAllCategories();
    notify();
  }

  void _addAllCategories() {
    ComponentCategories.values.forEach(_allowedCategories.add);
  }

  List<ComponentCategories> get allowedCategories => _allowedCategories;
}

enum ComponentsPage {
  allComponents,
  addComponent,
}

extension ComponentsPageExtension on ComponentsPage {
  String get pageName {
    switch (this) {
      case ComponentsPage.allComponents:
        return 'Alle Komponenten';
      case ComponentsPage.addComponent:
        return 'Komponente erstellen';
    }
  }
}
