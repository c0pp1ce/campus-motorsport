/// The user model used throughout the app.
///
/// Email is handled by the firebase auth module.
class User {
  User({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.accepted = false,
    this.isAdmin = false,
    this.verified = false,
    this.onSite = false,
  });

  /// Doc id is the same as the uid.
  String uid;
  String firstname;
  String lastname;
  String email;
  bool accepted;
  bool isAdmin;
  bool verified;
  bool onSite;

  String get name {
    return '$firstname $lastname';
  }

  /// verified is handled by Firebase auth and therefore not part of the user data entry.
  static User fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      accepted: json['accepted'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      verified: json['verified'] ?? false,
      onSite: json['onSite'] ?? false,
    );
  }

  // TODO : Needed?
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstname': firstname,
      'lastname': lastname,
      'accepted': accepted,
      'isAdmin': isAdmin,
      'verified': verified,
      'onSite': onSite,
    };
  }

  @override
  String toString() {
    return '$firstname $lastname, '
        '$uid\n'
        '(verified, accepted, isAdmin) : ($verified, $accepted, $isAdmin)\n';
  }
}
