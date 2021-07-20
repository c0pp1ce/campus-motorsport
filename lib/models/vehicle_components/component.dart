import 'data_input.dart';

/// Possible states of a component.
enum ComponentState {
  newComponent,
  ok,
  bad,
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

enum ComponentCategories {
  engine,
  undercarriage,
  aero,
  electrical,
  other,
}

/// The basic component.
class BaseComponent {
  BaseComponent({
    this.id,
    required this.name,
    required this.state,
    this.vehicleIds,
  });

  /// Equals docId in the components collection.
  final String? id;
  final String name;
  final ComponentState state;
  /// Ids of vehicles that use this component.
  final List<String>? vehicleIds;

  static BaseComponent fromJson(Map<String, dynamic> json) {
    final String stateName = json['state'];
    late ComponentState state;
    for(final ComponentState myState in ComponentState.values) {
      if(myState.name == stateName) {
        state = myState;
        break;
      }
    }
    assert(state != null, 'Invalid state stored in database: $stateName');

    return BaseComponent(
      id: json['id'],
      name: json['name'],
      state: state,
      vehicleIds: json['vehicleIds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'state': state.name,
      'vehicleIds': vehicleIds ?? [],
    };
  }
}

/// Blueprint for components that carry additional data fields;
class ExtendedComponent extends BaseComponent {
  ExtendedComponent({
    String? id,
    required String name,
    required ComponentState state,
    required this.additionalData,
  }) : super(
          id: id,
          name: name,
          state: state,
        );

  ExtendedComponent.fromBaseComponent({
    required BaseComponent baseComponent,
    required this.additionalData,
  }) : super(
          id: baseComponent.id,
          name: baseComponent.name,
          state: baseComponent.state,
        );

  /// The additional data fields;
  List<DataInput> additionalData;

  static ExtendedComponent fromJson(Map<String, dynamic> json) {
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
