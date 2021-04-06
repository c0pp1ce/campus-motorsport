import 'email.dart';

class User {
  String? id;
  String firstname;
  String lastname;
  Email accountEmail;

  User(this.firstname, this.lastname, this.accountEmail ,{this.id});

  factory User.fromJson(Map<String, dynamic> decodedJson) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonUser = new Map();
    if(id != null) jsonUser["id"] = id;
    jsonUser["firstname"] = firstname;
    jsonUser["lastname"] = lastname;
    jsonUser["email"] = accountEmail.email;
    return jsonUser;
  }

}