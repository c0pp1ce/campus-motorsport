import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CpTypes {
  raceDay,
  testDay,
  training,
  otherEvent,
}


/// Clipboards are markdown-capable text objects which are used to create info pages for
/// events like race days.
class Clipboard {
  Clipboard({
    required this.name,
    required this.content,
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

  static Clipboard fromJson(Map<String, dynamic> json, [String? id]) {
    late final DateTime date;
    if (json['creationDate'] is Timestamp) {
      date = (json['creationDate'] as Timestamp).toDate().toUtc();
    } else {
      date = DateTime.parse(json['creationDate']);
    }

    return Clipboard(
      name: json['name'],
      content: json['content'],
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
      if (withId && id != null) 'id': id,
      if (image?.url != null) 'image': image!.url,
    };
  }

  String copyContent() {
    return content;
  }
}
