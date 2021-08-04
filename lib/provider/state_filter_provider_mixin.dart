import 'package:campus_motorsport/models/components/component.dart';

/// Mixin to add filter logic based on component states.
mixin StateFilterProviderMixin {
  /// Needs to be initialized by classes which use this mixin.
  late final void Function() stateFilterNotify;

  /// Used to filter components list.
  final List<ComponentStates> _allowedStates = _init();

  void allowState(ComponentStates s) {
    if (!_allowedStates.contains(s)) {
      _allowedStates.add(s);
      stateFilterNotify();
    }
  }

  void hideState(ComponentStates s) {
    if (_allowedStates.remove(s)) {
      stateFilterNotify();
    }
  }

  void resetAllowedStates([bool notifyListeners = true]) {
    _allowedStates.clear();
    _addAllStates(_allowedStates);
    if (notifyListeners) {
      stateFilterNotify();
    }
  }

  static void _addAllStates(List<ComponentStates> states) {
    ComponentStates.values.forEach(states.add);
  }

  static List<ComponentStates> _init() {
    final List<ComponentStates> states = [];
    _addAllStates(states);
    return states;
  }

  List<ComponentStates> get allowedStates => _allowedStates;
}
