import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';

/// Determines which subpage of Component Containers(Vehicles and stock) should
/// be shown.
///
/// Also holds the current container which should be displayed.
class CCViewProvider extends BaseProvider {
  CCViewProvider({
    required this.vehicles,
    required this.stocks,
    required this.isAdmin,
  }) {
    _allowedCategories = [];
    _addAllCategories();
    if (stocks.isEmpty) {
      if (vehicles.isEmpty) {
        /// No vehicles or stocks found.
        if (isAdmin) {
          // Admins can add vehicles.
          currentPage = ComponentContainerPage.addContainer;
          allowContextDrawer = false;
        } else {
          currentPage = ComponentContainerPage.noContainers;
          allowContextDrawer = false;
        }
      } else {
        allowContextDrawer = true;
        currentPage = ComponentContainerPage.currentState;
        currentlyOpen = vehicles[0];
      }
    } else {
      allowContextDrawer = true;
      currentPage = ComponentContainerPage.currentState;
      currentlyOpen = stocks[0];
    }
  }

  late bool isAdmin;
  late bool allowContextDrawer;
  late ComponentContainerPage currentPage;

  List<ComponentContainer> vehicles;
  List<ComponentContainer> stocks;
  ComponentContainer? currentlyOpen;

  /// Used to filter components list.
  late List<ComponentCategories> _allowedCategories;

  /// Used to be able to easier build menus.
  static List<ComponentContainerPage> get containerSpecificPages {
    return const [
      ComponentContainerPage.currentState,
      ComponentContainerPage.updates,
      ComponentContainerPage.addUpdate,
      ComponentContainerPage.addEvent,
      ComponentContainerPage.addComponent,
    ];
  }

  static List<ComponentContainerPage> get containerSpecificAdminOnlyPages {
    return const [
      ComponentContainerPage.addEvent,
      ComponentContainerPage.addComponent,
    ];
  }

  /// Either switch pages of the current container or switch to another container.
  void switchTo(
    ComponentContainerPage page, {
    ComponentContainer? openContainer,
  }) {
    if (openContainer != null && openContainer.id != currentlyOpen?.id) {
      currentPage = ComponentContainerPage.currentState;
      currentlyOpen = openContainer;
      notify();
      return;
    }

    if (page != currentPage) {
      currentPage = page;
      if (currentPage == ComponentContainerPage.addEvent ||
          currentPage == ComponentContainerPage.noContainers ||
          currentPage == ComponentContainerPage.addContainer) {
        allowContextDrawer = false;
      } else {
        resetAllowedCategories(false);
        allowContextDrawer = true;
      }
      notify();
    }
  }

  /// Attention : If any widget is not listening to this provider but only
  /// to one of the data providers [VehiclesProvider] / [StocksProvider] then this
  /// widget will potentially not see any changes fetched by this reload.
  /// TODO : Determine if the data providers should send a notify instead since this provider listens to them.
  Future<void> reloadCurrentlyOpen() async {
    if (currentlyOpen?.id == null) {
      return;
    }
    late final List list;
    if (currentlyOpen!.type == ComponentContainerTypes.vehicle) {
      list = vehicles;
    } else {
      list = stocks;
    }

    final int index = list.indexOf(currentlyOpen);
    if (index == -1) {
      print('vehicle not found');
      return;
    } else {
      final ComponentContainer? c =
          await CrudCompContainer().getContainer(currentlyOpen!.id!);
      if (c != null) {
        list[index] = c;
        currentlyOpen = list[index];
      }
    }
    notify();
  }

  // Filter logic --------------------------------------------------------------
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

  void resetAllowedCategories([bool notifyListeners = true]) {
    _allowedCategories.clear();
    _addAllCategories();
    if (notifyListeners) {
      notify();
    }
  }

  void _addAllCategories() {
    ComponentCategories.values.forEach(_allowedCategories.add);
  }

  List<ComponentCategories> get allowedCategories => _allowedCategories;
// End Filter logic ------------------------------------------------------------
}

enum ComponentContainerPage {
  currentState,
  updates,
  addUpdate,
  addEvent,
  addComponent,
  addContainer,
  noContainers,
}

extension ComponentsPageExtension on ComponentContainerPage {
  String get pageName {
    switch (this) {
      case ComponentContainerPage.currentState:
        return 'Aktueller Zustand';
      case ComponentContainerPage.addUpdate:
        return 'Wartungen eintragen';
      case ComponentContainerPage.addEvent:
        return 'Event eintragen';
      case ComponentContainerPage.addContainer:
        return 'Fahrzeug/Lager hinzufügen';
      case ComponentContainerPage.updates:
        return 'Alle Wartungen';
      case ComponentContainerPage.addComponent:
        return 'Komponenten hinzufügen';
      case ComponentContainerPage.noContainers:
        return 'Nichts gefunden';
    }
  }
}
