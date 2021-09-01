import 'data_input.dart';

/// Possible states of a component.
/// Order matters!
enum ComponentState {
  bad,
  ok,
  newComponent,
}

extension ComponentStateNames on ComponentState {
  String get name {
    switch (this) {
      case ComponentState.newComponent:
        return 'Neu';
      case ComponentState.ok:
        return 'In Ordnung';
      case ComponentState.bad:
        return 'Nicht in Ordnung';
    }
  }
}

/// Sorted by their names order. See extension for those.
///
/// Order needed for compare function - in order to match the ordering done by
/// firebase (components collection).
enum ComponentCategories {
  aero,
  chassis,
  electrical,
  undercarriage,
  engine,
  other,
}

extension ComponentCategoryNames on ComponentCategories {
  String get name {
    switch (this) {
      case ComponentCategories.aero:
        return 'Aerodynamik';
      case ComponentCategories.chassis:
        return 'Chassis & Komponentenintegration';
      case ComponentCategories.electrical:
        return 'Elektrotechnik';
      case ComponentCategories.undercarriage:
        return 'Fahrwerk';
      case ComponentCategories.engine:
        return 'Motor & Antriebsstrang';
      case ComponentCategories.other:
        return 'Sonstiges';
    }
  }
}

/// The basic component.
class BaseComponent {
  BaseComponent({
    this.id,
    this.baseEventCounter,
    required this.name,
    required this.state,
    required this.category,
    this.usedBy,
  });

  /// Equals docId in the components collection.
  String? id;
  final String name;
  ComponentState state;

  /// Ids of vehicles that use this component.
  final List<String>? usedBy;
  ComponentCategories category;
  int? baseEventCounter;

  static BaseComponent fromJson(Map<String, dynamic> json) {
    final String stateName = json['state'];

    /// Get state.
    late ComponentState state;
    for (final ComponentState myState in ComponentState.values) {
      if (myState.name == stateName) {
        state = myState;
        break;
      }
    }
    assert(state != null, 'Invalid state stored in database: $stateName');

    /// Get category
    final String categoryName = json['category'];
    late ComponentCategories category;
    for (final ComponentCategories myCategory in ComponentCategories.values) {
      if (myCategory.name == categoryName) {
        category = myCategory;
        break;
      }
    }

    List<String>? _usedBy;
    if (json['usedBy'] != null) {
      _usedBy = (json['usedBy'] as List).cast<String>();
    }

    return BaseComponent(
      id: json['id'],
      name: json['name'],
      state: state,
      usedBy: _usedBy,
      category: category,
      baseEventCounter: json['baseEventCounter'],
    );
  }

  /// forUpdate skips the usedBy list as this is not needed in state updates.
  ///
  /// folder is used to have an easy way to delete images once a component-container
  /// is deleted.
  Future<Map<String, dynamic>> toJson({
    bool forUpdate = false,
    String? folder,
  }) async {
    assert(forUpdate && folder != null || !forUpdate);
    return {
      'id': id,
      'name': name,
      'state': state.name,
      if (!forUpdate) 'usedBy': usedBy ?? <String>[],
      'category': category.name,
      if (baseEventCounter != null) 'baseEventCounter': baseEventCounter!,
    };
  }

  static int compareComponents(BaseComponent a, BaseComponent b) {
    if (a.category != b.category) {
      return ComponentCategories.values
          .indexOf(a.category)
          .compareTo(ComponentCategories.values.indexOf(b.category));
    } else {
      return a.name.compareTo(b.name);
    }
  }
}

/// Blueprint for components that carry additional data fields;
class ExtendedComponent extends BaseComponent {
  ExtendedComponent({
    String? id,
    required String name,
    required ComponentState state,
    required this.additionalData,
    required ComponentCategories category,
  }) : super(
          id: id,
          name: name,
          state: state,
          category: category,
        );

  ExtendedComponent.fromBaseComponent({
    required BaseComponent baseComponent,
    required this.additionalData,
  }) : super(
          id: baseComponent.id,
          name: baseComponent.name,
          state: baseComponent.state,
          category: baseComponent.category,
          baseEventCounter: baseComponent.baseEventCounter,
        );

  /// The additional data fields;
  List<DataInput> additionalData;

  static ExtendedComponent fromJson(Map<String, dynamic> json,
      [String? docId]) {
    final BaseComponent baseComponent = BaseComponent.fromJson(json);
    final List<DataInput> additionalData = List.empty(growable: true);

    for (final Map<String, dynamic> dataInput in json['additionalData']) {
      additionalData.add(DataInput.fromJson(dataInput));
    }

    return ExtendedComponent.fromBaseComponent(
      baseComponent: baseComponent,
      additionalData: additionalData,
    );
  }

  @override
  Future<Map<String, dynamic>> toJson({
    bool forUpdate = false,
    String? folder,
  }) async {
    assert(forUpdate && folder != null || !forUpdate);

    /// Base info.
    final Map<String, dynamic> json =
        await super.toJson(forUpdate: forUpdate, folder: folder);
    final List<Map<String, dynamic>> fields = List.empty(growable: true);
    for (final DataInput dataInput in additionalData) {
      fields.add(await dataInput.toJson(forUpdate ? '${folder!}/$id' : name));
    }
    json['additionalData'] = fields;
    return json;
  }
}
