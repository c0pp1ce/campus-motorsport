import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple data wrapper for events which have effects on a vehicles state.
///
/// Currently only effecting the eventCounter of a component/update.
class Event {
  Event({
    required this.decrementCounterBy,
    required this.name,
    required this.by,
    required this.date,
    this.description,
  });

  int decrementCounterBy;
  String name;
  String by;
  DateTime date;
  String? description;

  static Event fromJson(Map<String, dynamic> json) {
    final Timestamp timestamp = json['date'];

    return Event(
      decrementCounterBy: json['decrementBy'],
      name: json['name'],
      by: json['by'],
      description: json['description'],
      date: timestamp.toDate().toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decrementBy': decrementCounterBy,
      'name': name,
      'by': by,
      'date': date.toUtc(),
      if (description?.isNotEmpty ?? false) 'description': description!,
    };
  }
}
