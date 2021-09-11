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
enum ComponentCategory {
  aero,
  chassis,
  electrical,
  undercarriage,
  engine,
  other,
}

extension ComponentCategoryNames on ComponentCategory {
  String get name {
    switch (this) {
      case ComponentCategory.aero:
        return 'Aerodynamik';
      case ComponentCategory.chassis:
        return 'Chassis & Komponentenintegration';
      case ComponentCategory.electrical:
        return 'Elektrotechnik';
      case ComponentCategory.undercarriage:
        return 'Fahrwerk';
      case ComponentCategory.engine:
        return 'Motor & Antriebsstrang';
      case ComponentCategory.other:
        return 'Sonstiges';
    }
  }
}

/// The basic component.
class BaseComponent {
  BaseComponent({
    required this.id,
    this.baseEventCounter,
    required this.name,
    required this.state,
    required this.category,
    this.usedBy,
  });

  /// This constructor is only used for creating a new component which therefore
  /// cannot posses an ID. Dont use it for any other purpose.
  BaseComponent.withoutId({
    this.baseEventCounter,
    required this.name,
    required this.state,
    required this.category,
    this.usedBy,
  }) : id = '';

  /// Equals docId in the components collection.
  String id;
  final String name;
  ComponentState state;

  /// Ids of vehicles that use this component.
  final List<String>? usedBy;
  ComponentCategory category;
  int? baseEventCounter;

  static BaseComponent fromJson(Map<String, dynamic> json, String docId) {
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
    late ComponentCategory category;
    for (final ComponentCategory myCategory in ComponentCategory.values) {
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
      id: docId,
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
  }) async {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'state': state.name,
      if (!forUpdate) 'usedBy': usedBy ?? <String>[],
      'category': category.name,
      if (baseEventCounter != null) 'baseEventCounter': baseEventCounter!,
    };
  }

  static int compareComponents(BaseComponent a, BaseComponent b) {
    if (a.category != b.category) {
      return ComponentCategory.values
          .indexOf(a.category)
          .compareTo(ComponentCategory.values.indexOf(b.category));
    } else {
      return a.name.compareTo(b.name);
    }
  }

  @override
  String toString() {
    return '$name : $id';
  }
}

/// Blueprint for components that carry additional data fields;
class ExtendedComponent extends BaseComponent {
  ExtendedComponent({
    required String id,
    required String name,
    required ComponentState state,
    required this.additionalData,
    required ComponentCategory category,
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

  /// This constructor is only used for creating a new component which therefore
  /// cannot posses an ID. Dont use it for any other purpose.
  ExtendedComponent.fromBaseComponentWithoutId({
    required BaseComponent baseComponent,
    required this.additionalData,
  }) : super.withoutId(
    name: baseComponent.name,
    state: baseComponent.state,
    category: baseComponent.category,
    baseEventCounter: baseComponent.baseEventCounter,
  );

  /// The additional data fields;
  List<DataInput> additionalData;

  static ExtendedComponent fromJson(Map<String, dynamic> json, String docId) {
    final BaseComponent baseComponent = BaseComponent.fromJson(json, docId);
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
    final Map<String, dynamic> json = await super.toJson(forUpdate: forUpdate);
    final List<Map<String, dynamic>> fields = List.empty(growable: true);
    for (final DataInput dataInput in additionalData) {
      fields.add(await dataInput.toJson(forUpdate ? '${folder!}/$id' : name));
    }
    json['additionalData'] = fields;
    return json;
  }
}
