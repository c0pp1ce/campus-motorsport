/// Possible input/data types
enum InputTypes {
  text,
  number,
  date,
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
    }
  }
}

/// Defines a data input field.
class DataInput {
  DataInput({
    required this.type,
    required this.name,
    required this.description,
  });

  InputTypes type;
  String name;
  String description;
  dynamic input;

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
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'type': type.name,
      'description': description,
    };
    if (input != null) {
      json['data'] = input;
    }
    return json;
  }
}
