import 'package:campus_motorsport/provider/base_provider.dart';

/// Determines which subpage of User Management should be shown.
class ComponentsViewProvider extends BaseProvider {
  ComponentsPage currentPage = ComponentsPage.allComponents;

  void switchTo(ComponentsPage page) {
    if (page != currentPage) {
      currentPage = page;
      notify();
    }
  }
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