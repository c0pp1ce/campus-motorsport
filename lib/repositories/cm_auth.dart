import 'package:campus_motorsport/models/user.dart' as app;
import 'package:campus_motorsport/repositories/cloud_functions.dart';
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
        email: email,
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
        await signOut();
        return null;
      }

      /// Update verification state.
      /// TODO : Change to firebase function if they add an onVerification event.
      if (!currentUser.verified && authUser.emailVerified) {
        await _crudUser.updateField(
            uid: currentUser.uid, key: 'verified', data: true);
        currentUser.verified = true;
      }

      final IdTokenResult token = await authUser.getIdTokenResult();

      /// Check if the claim has not been set yet.
      if (currentUser.accepted &&
          authUser.emailVerified &&
          (token.claims?['accepted'] != true)) {
        await addAcceptedRole(currentUser.email);
      }

      if (!currentUser.accepted || !authUser.emailVerified) {
        /// User does not possess the required role to login.
        await signOut();
        return null;
      }

      /// User is allowed to login.
      return currentUser;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  /// Used to be able to resend the verification email.
  ///
  /// Dont use this for the actual login as this method only checks Firebase auth
  /// and not the custom role system.
  Future<bool> loginToAuth(String email, String password) async {
    try {
      /// Perform auth login.
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return true;
      }
      return false;
    } on Exception catch (e) {
      print(e.toString());
      return false;
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

  Future<bool> sendVerificationEmail() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
