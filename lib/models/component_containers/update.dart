import 'package:campus_motorsport/models/components/component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// State update to one component. Stores the new component data as well as the
/// date of the update. Furthermore it contains an identifier by whom this update
/// has been made.
///
/// [date] needs to be as precise as possible.
class Update {
  Update({
    required this.component,
    required this.date,
    required this.by,
    this.eventCounter,
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
  int? eventCounter;

  static Update fromJson(Map<String, dynamic> json) {
    bool extendedComponent = false;
    // TODO : Move logic to toJson of BaseComponent. (As well as identify where this is needed as well).
    if ((json['component'] as Map<String, dynamic>)
        .containsKey('additionalData')) {
      extendedComponent = true;
    }

    final Timestamp timestamp = json['date'];
    return Update(
      component: extendedComponent
          ? ExtendedComponent.fromJson(json['component'])
          : BaseComponent.fromJson(json['component']),
      date: timestamp.toDate().toLocal(),
      by: json['by'],
      eventCounter: json['eventCounter'],
    );
  }

  Future<Map<String, dynamic>> toJson() async {
    return <String, dynamic>{
      'component': await component.toJson(forUpdate: true),
      'date': date.toUtc(),
      'by': by,
      if (eventCounter != null) 'eventCounter': eventCounter,
    };
  }
}
