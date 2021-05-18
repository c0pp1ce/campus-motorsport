import 'package:campus_motorsport/models/user/email.dart';
import 'package:campus_motorsport/models/user/user.dart' as cm;
import 'package:firebase_auth/firebase_auth.dart';

/// Handles the authentication with Firebase.
class CMAuth {
  final FirebaseAuth _firebaseAuth;

  CMAuth() : _firebaseAuth = FirebaseAuth.instance;

  cm.User? _userFromFirebase(UserCredential credential) {
    if (credential.user == null) {
      return null;
    }
    return new cm.User(
      uid: credential.user!.uid,
      accountEmail: Email(credential.user!.email ?? ''),
      name: credential.user!.displayName ?? '',
      emailVerified: credential.user!.emailVerified,
    );
  }

  Future<cm.User?> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    try {
      cm.User? user = _userFromFirebase(
        await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
      if(user != null) {
        /// TODO : save firstname, lastname.
        await _firebaseAuth.currentUser?.sendEmailVerification();
        return user;
      }
    } on FirebaseAuthException catch (e) {
    print(e.message);
    return null;
    }
  }

  Future<cm.User?> login({
    required String email,
    required String password,
  }) async {
    try {
      return _userFromFirebase(
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } on Exception catch(e) {
      print(e.toString());
      return null;
    }
  }
}
