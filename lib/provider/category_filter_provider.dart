import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/base_provider.dart';

/// Parent class for view providers which need to provide filter logic based on
/// component categories.
abstract class CategoryFilterProvider extends BaseProvider {
  CategoryFilterProvider() {
    _allowedCategories = [];
    _addAllCategories();
  }

  /// Used to filter components list.
  late List<ComponentCategories> _allowedCategories;

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
}
