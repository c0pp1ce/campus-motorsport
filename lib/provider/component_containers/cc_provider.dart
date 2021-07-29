import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:flutter/cupertino.dart';

class CCProvider extends BaseProvider {
  CCProvider({this.type});

  final CrudCompContainer _crudCompContainer = CrudCompContainer();
  ComponentContainerTypes? type;
  List<ComponentContainer>? _containers;

  List<ComponentContainer> get containers {
    if (_containers == null) {
      reload(false);
      return const [];
    }
    return _containers!;
  }

  List<ComponentContainer> getContainersBuildSafe() {
    if (_containers == null) {
      reload(true);
      return const [];
    }
    return _containers!;
  }

  Future<void> reload(bool buildSafe) async {
    /// Get all containers.
    final List<ComponentContainer> containers =
        await _crudCompContainer.getContainers() ?? [];

    /// Filter based on provider type.
    if (type != null) {
      _containers =
          containers.where((element) => element.type == type).toList();
    } else {
      _containers = containers;
    }
    if (buildSafe) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        notify();
      });
    } else {
      notify();
    }
  }
}

/// Extra class to be able to differentiate between the providers.
class VehiclesProvider extends CCProvider {
  VehiclesProvider() : super(type: ComponentContainerTypes.vehicle);
}

/// Extra class to be able to differentiate between the providers.
class StocksProvider extends CCProvider {
  StocksProvider() : super(type: ComponentContainerTypes.stock);
}
