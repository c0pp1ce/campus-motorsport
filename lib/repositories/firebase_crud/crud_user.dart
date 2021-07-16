import 'package:campus_motorsport/models/user.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Create, Read, Update, Delete users in firebase.
class CrudUser {
  CrudUser() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns the user data based on the uid or null if the request fails.
  Future<app.User?> getUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userData =
          await _firestore.collection('users').doc(uid).get();
      if (userData.data() == null) {
        return null;
      }
      return app.User.fromJson(userData.data()!);
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Creates a new user entry based on the current uid.
  /// the request fails if the document id is already taken.
  Future<bool> createUser({
    required String uid,
    required String firstname,
    required String lastname,
  }) async {
    try {
      /// Check if the uid is already taken to avoid overwriting data.
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return false;
      }

      /// Create the new user entry.
      await _firestore.collection('users').doc(uid).set(
        {
          'uid': uid,
          'firstname': firstname,
          'lastname': lastname,
        },
      );
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Attempts to delete the user from firebase auth.
  Future<bool> deleteUser({required String uid}) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Updates the content of a specific field of the user.
  Future<bool> updateField({
    required String uid,
    required String key,
    required dynamic data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        key: data,
      });
      return true;
    } on Exception catch (e) {
      print('Tried to update $key. Failed because of:\n');
      print(e.toString());
      return false;
    }
  }

  /// Updates multiple fields of the user.
  Future<bool> updateMultipleFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } on Exception catch (e) {
      print('Tried to update ${data.keys}. Failed because of:\n');
      print(e.toString());
      return false;
    }
  }
}
