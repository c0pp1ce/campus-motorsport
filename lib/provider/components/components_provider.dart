import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';

class ComponentsProvider extends BaseProvider {
  List<BaseComponent>? _components;
  final CrudComponent _crudComponent = CrudComponent();

  List<BaseComponent> get components {
    if (_components == null) {
      _components = [];
      reload();
    }
    return _components!;
  }

  Future<void> reload() async {
    print(_components);
    _components = await _crudComponent.getComponents() ?? [];
    print(_components);
    notify();
  }

  void addComponent(BaseComponent component) {
    if (_components != null) {
      _components!.add(component);
      notify();
    }
  }

  void removeComponent(BaseComponent component) {
    if (_components != null) {
      _components!.remove(component);
      notify();
    }
  }
}
