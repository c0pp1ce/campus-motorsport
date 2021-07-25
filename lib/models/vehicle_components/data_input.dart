import 'package:campus_motorsport/models/cm_image.dart';

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
    return DataInput(
      type: type,
      name: json['name'],
      description: json['description'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'type': type.name,
      'description': description,
    };
    if (data != null) {
      if (type != InputTypes.image) {
        json['data'] = data;
      } else {
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
