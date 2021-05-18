import 'email.dart';

/// Representation of the user of the app.
class User {
  final String? uid;
  String name;
  Email? accountEmail;
  bool isSuperuser;

  User({
    this.name = '',
    this.isSuperuser = false,
    this.uid,
    this.accountEmail,
  });

  /// Returns a dummy user if an error occurs.
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        name: json["name"],

        /// Email is only returned for GET /me.
        isSuperuser: json["is_superuser"],
        accountEmail: (json["email"] != null ? Email(json["email"]) : null),
        uid: json["uid"],
      );
    } on Exception catch (e) {
      print(e);
      return User(name: 'ERROR', isSuperuser: false);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonUser = new Map();
    jsonUser["name"] = name;
    if (accountEmail != null) jsonUser["email"] = accountEmail!.email;
    return jsonUser;
  }
}
