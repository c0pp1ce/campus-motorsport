import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';

class ComponentsProvider extends BaseProvider {
  List<BaseComponent>? _components;
  final CrudComponent _crudComponent = CrudComponent();

  Future<List<BaseComponent>> get components async {
    if (_components == null) {
      await reload();
    }
    return _components!;
  }

  Future<void> reload() async {
    _components = await _crudComponent.getComponents() ?? [];
    notify();
  }
}
