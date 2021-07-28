import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';

class CCProvider extends BaseProvider {
  CCProvider({this.type});

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
    _containers = [];
    //_containers = await _crudComponent.getComponents() ?? [];
    switch (type) {
      case ComponentContainerTypes.stock:
        // TODO: Only stocks.
        break;
      case ComponentContainerTypes.vehicle:
        // TODO : Only vehicles.
        break;
      case null:
        // TODO : All containers.
        break;
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
