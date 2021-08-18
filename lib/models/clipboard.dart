import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CpTypes {
  raceDay,
  testDay,
  training,
  otherEvent,
}

extension CpTypesNames on CpTypes {
  String get name {
    switch (this) {
      case CpTypes.raceDay:
        return 'Renntag';
      case CpTypes.testDay:
        return 'Testtag';
      case CpTypes.training:
        return 'Training';
      case CpTypes.otherEvent:
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
    DateTime? creationDate,
    this.id,
    this.image,
  }) {
    this.creationDate = creationDate ?? DateTime.now().toUtc();
  }

  String name;
  late DateTime creationDate;

  /// Can contain markdown syntax.
  String content;
  String? id;
  CMImage? image;
  CpTypes type;

  static Clipboard fromJson(Map<String, dynamic> json, [String? id]) {
    late final DateTime date;
    if (json['creationDate'] is Timestamp) {
      date = (json['creationDate'] as Timestamp).toDate().toUtc();
    } else {
      date = DateTime.parse(json['creationDate']);
    }
    late CpTypes type;
    for (final value in CpTypes.values) {
      if (json['type'] == value.name) {
        type = value;
        break;
      }
    }

    return Clipboard(
      name: json['name'],
      content: json['content'],
      type: type,
      creationDate: date,
      id: id ?? json['id'],
      image: json['image'] != null ? CMImage.fromUrl(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson([bool withId = false]) {
    return {
      'name': name,
      'content': content,
      'creationDate': creationDate,
      'type': type.name,
      if (withId && id != null) 'id': id,
      if (image?.url != null) 'image': image!.url,
    };
  }

  String copyContent() {
    return content;
  }
}
