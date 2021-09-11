import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CpType {
  raceDay,
  testDay,
  training,
  otherEvent,
}

extension CpTypesNames on CpType {
  String get name {
    switch (this) {
      case CpType.raceDay:
        return 'Renntag';
      case CpType.testDay:
        return 'Testtag';
      case CpType.training:
        return 'Training';
      case CpType.otherEvent:
        return 'Anderes Event';
    }
  }
}

/// Clipboards are markdown-capable text objects which are used to create info pages for
/// events like race days.
class Clipboard {
  Clipboard({
    required this.name,
    required this.content,
    required this.type,
    required this.eventDate,
    required this.id,
    this.image,
  });

  String name;
  late DateTime eventDate;

  /// Can contain markdown syntax.
  String content;
  String id;
  CMImage? image;
  CpType type;

  static Clipboard fromJson(Map<String, dynamic> json, String id) {
    late final DateTime date;
    if (json['eventDate'] is Timestamp) {
      date = (json['eventDate'] as Timestamp).toDate().toUtc();
    } else {
      date = DateTime.parse(json['eventDate']);
    }
    late CpType type;
    for (final value in CpType.values) {
      if (json['type'] == value.name) {
        type = value;
        break;
      }
    }

    return Clipboard(
      name: json['name'],
      content: json['content'],
      type: type,
      eventDate: date,
      id: id,
      image: json['image'] != null ? CMImage.fromUrl(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson([bool withId = false]) {
    return {
      'name': name,
      'content': content,
      'eventDate': eventDate,
      'type': type.name,
      if (withId) 'id': id,
      if (image?.url != null) 'image': image!.url,
    };
  }

  String copyContent() {
    return content;
  }
}
