/// The user model used throughout the app.
///
/// Email is handled by the firebase auth module.
class User {
  User({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.role,
    this.docId,
  });

  String uid;
  String? docId;
  String firstname;
  String lastname;
  UserRole role;

  static User fromJson(Map<String, dynamic> json, [String? docId]) {
    /// Convert the user role from String to enum value.
    final String roleValue = json['role'];
    late UserRole userRole;
    for (final role in UserRole.values) {
      if (roleValue == role.value) {
        userRole = role;
      }
    }
    assert(userRole != null, 'Could not find a matching user role.');

    return User(
      uid: json['uid'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      role: userRole,
      docId: docId,
    );
  }

  // TODO : Needed?
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstname': firstname,
      'lastname': lastname,
      'role': role.value,
    };
  }

  @override
  String toString() {
    return '$firstname $lastname\n$uid\n$role';
  }
}

/// A user can only have one role at a time.
/// [UserRole.accepted] is the first role which grants access to the app.
enum UserRole {
  unverified,
  verified,
  accepted,
  admin,
}

/// Used to have easy to read values stored in the database.
extension UserRolesExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.unverified:
        return 'unverified';
      case UserRole.verified:
        return 'verified';
      case UserRole.accepted:
        return 'accepted';
      case UserRole.admin:
        return 'admin';
    }
  }
}
