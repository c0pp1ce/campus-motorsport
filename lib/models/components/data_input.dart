import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Possible input/data types
enum InputTypes {
  text,
  number,
  date,
  image,
}

extension InputTypesNames on InputTypes {
  String get name {
    switch (this) {
      case InputTypes.text:
        return 'Text';
      case InputTypes.number:
        return 'Zahl';
      case InputTypes.date:
        return 'Datum';
      case InputTypes.image:
        return 'Bild';
    }
  }
}

/// Defines a data input field.
///
/// [InputTypes.image] --> data needs to be of type [CMImage].
class DataInput {
  DataInput({
    required this.type,
    required this.name,
    required this.description,
    this.data,
  });

  InputTypes type;
  String name;
  String description;
  dynamic data;

  static DataInput fromJson(Map<String, dynamic> json) {
    final String typeName = json['type'];
    late InputTypes type;
    for (final InputTypes myType in InputTypes.values) {
      if (myType.name == typeName) {
        type = myType;
        break;
      }
    }
    assert(type != null, 'Invalid type stored in database: $typeName');
    dynamic data;

    if (type == InputTypes.image && json['data'] != null) {
      data = CMImage.fromUrl(json['data']);
    } else if (type == InputTypes.date && json['data'] != null) {
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

  /// If of type [InputTypes.image] upload function of [CMImage] is called if its
  /// url is null.
  Future<Map<String, dynamic>> toJson(String folder) async {
    final Map<String, dynamic> json = {
      'name': name,
      'type': type.name,
      'description': description,
    };

    /// Check if there is data to be stored.
    if (data != null) {
      if (type != InputTypes.image) {
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
