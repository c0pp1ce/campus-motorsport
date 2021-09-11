import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/category_filter_provider.dart';
import 'package:campus_motorsport/provider/state_filter_provider_mixin.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';

/// Determines which subpage of Component Containers(Vehicles and stock) should
/// be shown.
///
/// Also holds the current container which should be displayed.
class CCViewProvider extends CategoryFilterProvider
    with StateFilterProviderMixin {
  CCViewProvider({
    required this.vehicles,
    required this.stocks,
    required this.isAdmin,
    required this.toggle,
  }) : super() {
    /// Required when using the [StateFilterProviderMixin].
    stateFilterNotify = notify;
    if (stocks.isEmpty) {
      if (vehicles.isEmpty) {
        /// No vehicles or stocks found.
        if (isAdmin) {
          // Admins can add vehicles.
          currentPage = ComponentContainerPage.addContainer;
          _allowContextDrawer = false;
        } else {
          currentPage = ComponentContainerPage.noContainers;
          _allowContextDrawer = false;
        }
      } else {
        _allowContextDrawer = true;
        currentPage = ComponentContainerPage.currentState;
        currentlyOpen = vehicles[0];
      }
    } else {
      _allowContextDrawer = true;
      currentPage = ComponentContainerPage.currentState;
      currentlyOpen = stocks[0];
    }
  }

  final void Function([bool]) toggle;

  late bool isAdmin;
  late bool _allowContextDrawer;
  late ComponentContainerPage currentPage;

  bool get allowContextDrawer => _allowContextDrawer;

  set allowContextDrawer(bool value) {
    _allowContextDrawer = value;
    notify();
  }

  List<ComponentContainer> vehicles;
  List<ComponentContainer> stocks;
  ComponentContainer? currentlyOpen;

  /// Used to be able to easier build menus.
  static List<ComponentContainerPage> get containerSpecificPages {
    return const [
      ComponentContainerPage.currentState,
      ComponentContainerPage.updates,
      ComponentContainerPage.events,
      ComponentContainerPage.allComponents,
      ComponentContainerPage.addUpdate,
      ComponentContainerPage.addComponent,
    ];
  }

  static List<ComponentContainerPage> get containerSpecificAdminOnlyPages {
    return const [
      ComponentContainerPage.addComponent,
    ];
  }

  /// Either switch pages of the current container or switch to another container.
  void switchTo(
    ComponentContainerPage page, {
    ComponentContainer? openContainer,
    bool toggleDrawer = true,
    bool onlyToggleToOpen = false,
  }) {
    if (openContainer != null && openContainer.id != currentlyOpen?.id) {
      currentPage = ComponentContainerPage.currentState;
      currentlyOpen = openContainer;
      _allowContextDrawer = true;
      resetAllowedCategories(false);
      resetAllowedStates(false);
      if (toggleDrawer) {
        toggle(onlyToggleToOpen);
      }
      notify();
      return;
    }

    if (page != currentPage) {
      currentPage = page;
      if (currentPage == ComponentContainerPage.events ||
          currentPage == ComponentContainerPage.noContainers ||
          currentPage == ComponentContainerPage.addContainer) {
        _allowContextDrawer = false;
      } else {
        resetAllowedCategories(false);
        resetAllowedStates(false);
        _allowContextDrawer = true;
      }
      if (toggleDrawer) {
        toggle(onlyToggleToOpen);
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
    late final List<ComponentContainer> list;
    if (currentlyOpen!.type == ComponentContainerType.vehicle) {
      list = vehicles;
    } else {
      list = stocks;
    }

    int index = list.indexOf(currentlyOpen!);
    if (index == -1) {
      final componentInList = list.firstWhere(
        (element) => element.id == currentlyOpen?.id,
        orElse: () => ComponentContainer(
          id: '',
          name: '',
          type: ComponentContainerType.vehicle,
        ),
      );
      if (componentInList.id.isNotEmpty) {
        index = list.indexOf(componentInList);
      }
    }
    if (index == -1) {
      print('vehicle not found');
      return;
    } else {
      final ComponentContainer? c =
          await CrudCompContainer().getContainer(currentlyOpen!.id);
      if (c != null) {
        list[index] = c;
        currentlyOpen = list[index];
      }
    }
    notify();
  }
}

enum ComponentContainerPage {
  currentState,
  updates,
  events,
  allComponents,
  addUpdate,
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
      case ComponentContainerPage.events:
        return 'Events';
      case ComponentContainerPage.addContainer:
        return 'Fahrzeug/Lager hinzufügen';
      case ComponentContainerPage.updates:
        return 'Alle Wartungen';
      case ComponentContainerPage.addComponent:
        return 'Komponenten hinzufügen';
      case ComponentContainerPage.allComponents:
        return 'Alle Komponenten';
      case ComponentContainerPage.noContainers:
        return 'Nichts gefunden';
    }
  }
}
