import 'email.dart';

/// Representation of the user of the app.
class User {
  final String? uid;
  String name;
  Email? accountEmail;
  bool isAdmin;
  /// Registration status.
  bool emailVerified;
  bool accepted;

  User({
    this.name = '',
    this.isAdmin = false,
    this.uid,
    this.accountEmail,
    this.emailVerified = false,
    this.accepted = false,
  });

  /// Returns a dummy user if an error occurs.
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        name: json["name"],

        /// Email is only returned for GET /me.
        isAdmin: json["isAdmin"],
        accountEmail: (json["email"] != null ? Email(json["email"]) : null),
        uid: json["uid"],
      );
    } on Exception catch (e) {
      print(e);
      return User(name: 'ERROR', isAdmin: false);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonUser = new Map();
    jsonUser["name"] = name;
    if (accountEmail != null) jsonUser["email"] = accountEmail!.email;
    return jsonUser;
  }
}
