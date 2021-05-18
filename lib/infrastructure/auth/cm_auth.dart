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
    );
  }

  bool register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String code,
  }) {
    throw UnimplementedError();
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
