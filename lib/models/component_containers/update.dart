import 'package:campus_motorsport/models/components/component.dart';

/// State update to one component. Stores the new component data as well as the
/// date of the update. Furthermore it contains an identifier by whom this update
/// has been made.
class Update {
  Update({
    required this.component,
    required this.date,
    required this.by,
    this.automaticUpdateAfterRides,
  });

  /// The data of the updated component.
  BaseComponent component;

  /// Date of the update.
  DateTime date;

  /// Identifier who made the update.
  String by;

  /// Used to determine if a new state change should be done after this amount of
  /// rides. Only considered if this is set in the update which is part of the
  /// current-state of a [ComponentsContainer].
  int? automaticUpdateAfterRides;

  static Update fromJson(Map<String, dynamic> json) {
    bool extendedComponent = false;
    // TODO : Move logic to toJson of BaseComponent. (As well as identify where this is needed as well).
    if ((json['component'] as Map<String, dynamic>)
        .containsKey('additionalData')) {
      extendedComponent = true;
    }

    return Update(
      component: extendedComponent
          ? ExtendedComponent.fromJson(json['component'])
          : BaseComponent.fromJson(json['component']),
      date: DateTime.parse(json['date']).toLocal(),
      by: json['by'],
    );
  }

  Future<Map<String, dynamic>> toJson() async {
    return <String, dynamic>{
      'component': await component.toJson(),
      'date': date.toUtc(),
      'by': by,
    };
  }
}
