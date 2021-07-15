import 'package:campus_motorsport/models/user.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles the authentication with Firebase.
class CMAuth {
  CMAuth()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Returns an [app.User] object if the registration is successful.
  Future<app.User?> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    try {
      /// Perform registration.
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Check success.
      final User? registeredUser = credential.user;
      if (registeredUser == null) {
        print('Error while performing registration.');
        return null;
      }

      /// Update user data for firebase auth.
      await registeredUser.updateProfile(
        displayName: '$firstname $lastname',
      );

      /// Create user entry in database.
      /// TODO : Implement CRUD methods.
      await _firestore.collection('users').add(
        {
          'uid': registeredUser.uid,
          'firstname': firstname,
          'lastname': lastname,
          'role': app.UserRole.unverified.value,
        },
      );

      /// Send verification email.
      await _firebaseAuth.currentUser?.sendEmailVerification();

      /// Return the current user
      return getUser(registeredUser.uid);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  /// Returns an [app.User] object if the login is successful or null if it fails.
  Future<app.User?> login({
    required String email,
    required String password,
  }) async {
    try {
      /// Perform auth login.
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Check success
      final User? authUser = credential.user;
      if (authUser == null) {
        return null;
      }

      /// Get the users data.
      final app.User? currentUser = await getUser(authUser.uid);
      if (currentUser == null) {
        return null;
      }

      /// Check user does not have the required role to be allowed to login to the app.
      if (currentUser.role != app.UserRole.accepted ||
          currentUser.role != app.UserRole.admin) {
        /// Check if email verification state has changed.
        if (currentUser.role == app.UserRole.unverified &&
            authUser.emailVerified) {
          /// TODO : Implement CRUD methods.
          print('Updating verified state');
          _firestore.collection('users').doc(currentUser.docId).update({
            'role': app.UserRole.verified.value,
          });
        }

        /// User does not possess any of the the required roles.
        return null;
      }

      /// User is allowed to login.
      return currentUser;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  /// Returns true if the signOut is successful or false otherwise.
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // TODO : Move
  Future<app.User?> getUser(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> userData =
        await _firestore.collection('users').where('uid', isEqualTo: uid).get();
    if (userData.docs.length != 1) {
      print('Something went wrong. Either 0 or multiple user entries found.');
      return null;
    } else if (userData.docs[0] == null) {
      print('User document is null.');
      return null;
    } else {
      return app.User.fromJson(userData.docs[0].data(), userData.docs[0].id);
    }
  }
}
