import 'package:campus_motorsport/models/user.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Create, Read, Update, Delete users in firebase.
class CrudUser {
  CrudUser() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Creates a new user entry based on the current uid.
  /// The request fails if the document id is already taken.
  Future<bool> createUser({
    required String uid,
    required String firstname,
    required String lastname,
    required String email,
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
          'email': email,
        },
      );
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

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

  Future<List<app.User>?> getUsers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> result =
          await _firestore.collection('users').orderBy('firstname').get();

      final List<app.User> resultList = List.empty(growable: true);
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in result.docs) {
        resultList.add(app.User.fromJson(doc.data()));
      }

      return resultList;
    } on Exception catch (e) {
      print('Tried to get all users. Failed because of:\n');
      print(e.toString());
      return null;
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

  /// Attempts to delete the user from firebase auth.
  Future<bool> deleteUser(
      {required String uid, bool deleteSelf = false}) async {
    if (uid == FirebaseAuth.instance.currentUser?.uid && !deleteSelf) {
      return false;
    }
    // TODO
    return false;
    try {
      await _firestore.collection('users').doc(uid).delete();
      // TODO : Delete from auth. (Trigger cloud function).
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
