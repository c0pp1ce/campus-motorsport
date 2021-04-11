import 'email.dart';

/// Representation of the user of the app.
class User {
  int? id;
  String firstname;
  String lastname;
  Email? accountEmail;
  bool isSuperuser;

  User(this.firstname, this.lastname, this.accountEmail, this.isSuperuser,
      {this.id});

  /// Returns a dummy user if an error occurs.
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        json["firstname"],
        json["lastname"],
        /// Email is only returned for GET /me.
        (json["email"] != null ? Email(json["email"]) : null),
        json["is_superuser"],
        id: json["id"],
      );
    } on Error catch (error) {
      print(error);
      return User('ERROR', 'ERROR', Email('ERROR'), false);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonUser = new Map();
    jsonUser["firstname"] = firstname;
    jsonUser["lastname"] = lastname;
    if(accountEmail != null) jsonUser["email"] = accountEmail!.email;
    return jsonUser;
  }
}
