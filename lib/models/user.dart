/// The user model used throughout the app.
///
/// Email is handled by the firebase auth module.
class User {
  User({
    required this.uid,
    required this.firstname,
    required this.lastname,
    this.accepted = false,
    this.isAdmin = false,
    this.verified = false,
  });

  /// Doc id is the same as the uid.
  String uid;
  String firstname;
  String lastname;
  bool accepted;
  bool isAdmin;
  bool verified;

  String get name {
    return '$firstname $lastname';
  }

  /// verified is handled by Firebase auth and therefore not part of the user data entry.
  static User fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      accepted: json['accepted'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      verified: json['verified'] ?? false,
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
    };
  }

  @override
  String toString() {
    return '$firstname $lastname\n'
        '$uid\n'
        '(verified, accepted, isAdmin) : ($verified, $accepted, $isAdmin)';
  }
}
