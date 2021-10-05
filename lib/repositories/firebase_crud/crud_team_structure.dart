import 'dart:io';

import 'package:campus_motorsport/models/team_structure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Currently only works with static storagePath & id. Rewrite if more versatility is
/// needed.
class CrudTeamStructure {
  final _firestore = FirebaseFirestore.instance;
  static String id = 'most-recent';

  Future<TeamStructure?> get() async {
    try {
      final doc = await _firestore.collection('team-structure').doc(id).get();
      if (doc.data() == null) {
        return null;
      }
      return TeamStructure.fromJson(doc.data()!, doc.id);
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  /// Only one valid, no need to add different items etc.
  Future<bool> setTeamStructure(TeamStructure teamStructure) async {
    assert(teamStructure.localFilePath != null);
    try {
      await _firestore.collection('team-structure').doc(id).set(
            teamStructure.toJson(),
          );
      final storage = FirebaseStorage.instance;
      final uploadTask = storage.ref(TeamStructure.storagePath).putFile(
            File(teamStructure.localFilePath!),
          );
      final taskSnapshot = await uploadTask.whenComplete(() => null);

      /// Check success
      if (taskSnapshot.state != TaskState.success) {
        return false;
      }

      /// Retrieve and save url
      final String url = await taskSnapshot.ref.getDownloadURL();
      await _firestore.collection('team-structure').doc(id).update(
        {
          'url': url,
        },
      );
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> delete(TeamStructure teamStructure) async {
    try {
      await _firestore.collection('team-structure').doc(id).delete();
      await FirebaseStorage.instance.ref(TeamStructure.storagePath).delete();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
