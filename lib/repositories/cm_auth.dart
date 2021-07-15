import 'package:campus_motorsport/models/user.dart' as app;
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles the authentication with Firebase.
class CMAuth {
  CMAuth()
      : _firebaseAuth = FirebaseAuth.instance,
        _crudUser = CrudUser();

  final FirebaseAuth _firebaseAuth;
  final CrudUser _crudUser;

  /// Returns an [app.User] object if the registration is successful.
  Future<bool> register({
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
        return false;
      }

      /// Update user data for firebase auth.
      await registeredUser.updateProfile(
        displayName: '$firstname $lastname',
      );

      /// Create user entry in database. Doc id == uid.
      if (!await _crudUser.createUser(
        uid: registeredUser.uid,
        firstname: firstname,
        lastname: lastname,
      )) {
        print('Could not create the user entry.');

        /// Cleanup.
        await registeredUser.delete();
        return false;
      }

      /// Send verification email.
      await _firebaseAuth.currentUser?.sendEmailVerification();

      /// Sign out the registered user as there are more steps before the app can be used.
      await signOut();

      /// Return the registered user.
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return false;
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
      final app.User? currentUser = await _crudUser.getUser(authUser.uid);
      if (currentUser == null) {
        return null;
      }

      if (!currentUser.accepted) {
        /// User does not possess the required role to login.
        return null;
      }

      /// User is allowed to login.
      return currentUser;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    } on Exception catch (e) {
      print('Update of verified failed.\n');
      print(e.toString());
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
}
