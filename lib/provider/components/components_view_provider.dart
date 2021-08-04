import 'package:campus_motorsport/provider/category_filter_provider.dart';

/// Determines which subpage of User Management should be shown.
class ComponentsViewProvider extends CategoryFilterProvider {
  ComponentsViewProvider({
    required this.toggle,
  }) : super();

  final void Function() toggle;
  ComponentsPage currentPage = ComponentsPage.allComponents;
  bool allowContextDrawer = true;

  void switchTo(ComponentsPage page) {
    if (page != currentPage) {
      currentPage = page;
      if (currentPage == ComponentsPage.allComponents) {
        allowContextDrawer = true;
      } else {
        allowContextDrawer = false;
      }
      toggle();
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
