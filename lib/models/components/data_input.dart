import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Possible input/data types
enum InputType {
  text,
  number,
  date,
  image,
}

extension InputTypesNames on InputType {
  String get name {
    switch (this) {
      case InputType.text:
        return 'Text';
      case InputType.number:
        return 'Zahl';
      case InputType.date:
        return 'Datum';
      case InputType.image:
        return 'Bild';
    }
  }
}

/// Defines a data input field.
///
/// [InputType.image] --> data needs to be of type [CMImage].
class DataInput {
  DataInput({
    required this.type,
    required this.name,
    required this.description,
    this.data,
  });

  InputType type;
  String name;
  String description;
  dynamic data;

  static DataInput fromJson(Map<String, dynamic> json) {
    final String typeName = json['type'];
    late InputType type;
    for (final InputType myType in InputType.values) {
      if (myType.name == typeName) {
        type = myType;
        break;
      }
    }
    assert(type != null, 'Invalid type stored in database: $typeName');
    dynamic data;

    if (type == InputType.image && json['data'] != null) {
      data = CMImage.fromUrl(json['data']);
    } else if (type == InputType.date && json['data'] != null) {
      final Timestamp timestamp = json['data'];
      data = timestamp.toDate();
    } else {
      data = json['data'];
    }

    return DataInput(
      type: type,
      name: json['name'],
      description: json['description'],
      data: data,
    );
  }

  /// If of type [InputType.image] upload function of [CMImage] is called if its
  /// url is null.
  Future<Map<String, dynamic>> toJson(String folder) async {
    final Map<String, dynamic> json = {
      'name': name,
      'type': type.name,
      'description': description,
    };

    /// Check if there is data to be stored.
    if (data != null) {
      if (type != InputType.image) {
        /// Generic types that can be stored inside of the db.
        json['data'] = data;
      } else {
        /// Only store URL of the image inside the db.
        if ((data as CMImage).url == null) {
          print('attempt to upload image');
          await (data as CMImage).uploadImageToFirebaseStorage(folder);
        }
        final String? url = (data as CMImage).url;
        if (url != null) {
          json['data'] = url;
        }
      }
    }
    return json;
  }

  @override
  String toString() {
    return '${type.name} - $name - $description - ${data ?? ''}';
  }
}
