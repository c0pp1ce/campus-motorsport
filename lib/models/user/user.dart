import 'email.dart';

class User {
  String firstname;
  String lastname;
  Email accountEmail;

  User(this.firstname, this.lastname, this.accountEmail);

  factory User.fromJson(Map<String, dynamic> decodedJson) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonUser = new Map();
    jsonUser["firstname"] = firstname;
    jsonUser["lastname"] = lastname;
    jsonUser["email"] = accountEmail.email;
    return jsonUser;
  }

}