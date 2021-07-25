import 'data_input.dart';

/// Possible states of a component.
/// Order matters!
enum ComponentStates {
  bad,
  ok,
  newComponent,
}

extension ComponentStateNames on ComponentStates {
  String get name {
    switch (this) {
      case ComponentStates.newComponent:
        return 'Neu';
      case ComponentStates.ok:
        return 'In Ordnung';
      case ComponentStates.bad:
        return 'Nicht in Ordnung';
    }
  }
}

enum ComponentCategories {
  engine,
  undercarriage,
  aero,
  electrical,
  other,
}

extension ComponentCategoryNames on ComponentCategories {
  String get name {
    switch (this) {
      case ComponentCategories.engine:
        return 'Motor';
      case ComponentCategories.undercarriage:
        return 'Fahrwerk';
      case ComponentCategories.aero:
        return 'Aero';
      case ComponentCategories.electrical:
        return 'Elektrotechnik';
      case ComponentCategories.other:
        return 'Sonstiges';
    }
  }
}

/// The basic component.
class BaseComponent {
  BaseComponent({
    this.id,
    required this.name,
    required this.state,
    required this.category,
    this.usedBy,
  });

  /// Equals docId in the components collection.
  final String? id;
  final String name;
  ComponentStates state;

  /// Ids of vehicles that use this component.
  final List<String>? usedBy;
  ComponentCategories category;

  static BaseComponent fromJson(Map<String, dynamic> json, [String? docId]) {
    final String stateName = json['state'];

    /// Get state.
    late ComponentStates state;
    for (final ComponentStates myState in ComponentStates.values) {
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
    if(json['usedBy'] != null) {
      _usedBy = (json['usedBy'] as List).cast<String>();
    }

    return BaseComponent(
      id: docId,
      name: json['name'],
      state: state,
      usedBy: _usedBy,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'state': state.name,
      'usedBy': usedBy ?? <String>[],
      'category': category.name,
    };
  }
}

/// Blueprint for components that carry additional data fields;
class ExtendedComponent extends BaseComponent {
  ExtendedComponent({
    String? id,
    required String name,
    required ComponentStates state,
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
        );

  /// The additional data fields;
  List<DataInput> additionalData;

  static ExtendedComponent fromJson(Map<String, dynamic> json,
      [String? docId]) {
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
  Map<String, dynamic> toJson() {
    /// Base info.
    final Map<String, dynamic> json = super.toJson();
    final List<Map<String, dynamic>> fields = List.empty(growable: true);
    for (final DataInput dataInput in additionalData) {
      fields.add(dataInput.toJson());
    }
    json['additionalData'] = fields;
    return json;
  }
}
