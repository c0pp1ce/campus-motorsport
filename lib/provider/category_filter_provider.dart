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
  late List<ComponentCategory> _allowedCategories;

  void allowCategory(ComponentCategory c) {
    if (!_allowedCategories.contains(c)) {
      _allowedCategories.add(c);
      notify();
    }
  }

  void hideCategory(ComponentCategory c) {
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
    ComponentCategory.values.forEach(_allowedCategories.add);
  }

  List<ComponentCategory> get allowedCategories => _allowedCategories;
}
