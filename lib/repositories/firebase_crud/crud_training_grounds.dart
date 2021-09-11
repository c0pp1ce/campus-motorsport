import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/training_ground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

/// Methods to read [TrainingGround] from Firebase, update its image url and
/// delete it.
class CrudTrainingGrounds {
  CrudTrainingGrounds() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<TrainingGround>?> getAll() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query =
          await _firestore.collection('training-grounds').orderBy('name').get();
      final List<TrainingGround> results = List.empty(growable: true);
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in query.docs) {
        final Map<String, dynamic> data = doc.data();
        CMImage? image;
        if (data['image'] == null) {
          image = CMImage.fromUrl(
            await FirebaseStorage.instance
                .ref(data['storagePath'])
                .getDownloadURL(),
          );
          await _updateUrl(doc.id, image.url!);
        } else if ((await http.get(Uri.parse(data['image']))).statusCode ==
            403) {
          image = CMImage.fromUrl(
            await FirebaseStorage.instance
                .ref(data['storagePath'])
                .getDownloadURL(),
          );
          await _updateUrl(doc.id, image.url!);
        }
        results.add(TrainingGround.fromJson(
          doc.data(),
          doc.id,
          image: image,
        ));
      }
      return results;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> _updateUrl(String docId, String url) async {
    try {
      await _firestore.collection('training-grounds').doc(docId).update(
        {
          'image': url,
        },
      );
      await _updateMetaInfo();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  /// Sets the current date as lastUpdated.
  Future<bool> _updateMetaInfo() async {
    try {
      await _firestore.collection('meta-info').doc('training-grounds').update(
        {
          'lastUpdate': DateTime.now().toUtc(),
        },
      );
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<DateTime> getLastUpdate() async {
    try {
      final doc = await _firestore
          .collection('meta-info')
          .doc('training-grounds')
          .get();
      if (doc.data()?['lastUpdate'] != null) {
        if (doc.data()!['lastUpdate'] is Timestamp) {
          return (doc.data()!['lastUpdate'] as Timestamp).toDate().toUtc();
        } else {
          return DateTime.parse(doc.data()!['lastUpdate']).toUtc();
        }
      } else {
        return DateTime.utc(1900);
      }
    } on Exception catch (e) {
      print(e);
      return DateTime.utc(1900);
    }
  }

  Future<bool> delete(String docId, String storagePath) async {
    try {
      await _firestore.collection('training-grounds').doc(docId).delete();
      await FirebaseStorage.instance.ref(storagePath).delete();
      await _updateMetaInfo();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
