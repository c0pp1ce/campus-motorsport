import 'package:campus_motorsport/models/cm_image.dart';

class TrainingGround {
  TrainingGround({
    required this.id,
    required this.name,
    required this.image,
    required this.storagePath,
    required this.lastUpdate,
  });

  /// Id of the firebase document.
  String id;
  String name;
  CMImage image;

  /// Set by the cloud function and also used for the locally stored image file.
  String storagePath;

  /// Stored as UTC.
  final DateTime lastUpdate;

  static TrainingGround fromJson(
    Map<String, dynamic> json,
    DateTime lastUpdate,
    String id, {
    CMImage? image,
  }) {
    assert(json['image'] != null || image != null);
    return TrainingGround(
      id: id,
      name: json['name'],
      image: image ?? CMImage.fromUrl(json['image']),
      storagePath: json['storagePath'],
      lastUpdate: lastUpdate,
    );
  }

  Map<String, dynamic> toJson() {
    assert(image.url != null);
    return {
      'id': id,
      'name': name,
      'image': image.url!,
      'storagePath': storagePath,
    };
  }
}