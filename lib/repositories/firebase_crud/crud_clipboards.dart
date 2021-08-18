import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/models/cm_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudClipboards {
  final _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'clipboards';

  Future<bool> create(Clipboard clipboard) async {
    try {
      final doc =
          await _firestore.collection(collectionName).add(clipboard.toJson());
      clipboard.id = doc.id;
      if (clipboard.image != null) {
        await clipboard.image!
            .uploadImageToFirebaseStorage('clipboards/${clipboard.id}');
        await _firestore.collection(collectionName).doc(clipboard.id).update({
          'image': clipboard.image?.url,
        });
      }
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  /// Image update currently not supported.
  Future<bool> update(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) {
      return false;
    }
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (!doc.exists) {
        return false;
      }
      await _firestore.collection(collectionName).doc(id).update(data);
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<Clipboard?> getOne(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (doc.data() == null) {
        return null;
      }
      return Clipboard.fromJson(doc.data()!, doc.id);
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Clipboard>?> getAll() async {
    try {
      final docs = await _firestore
          .collection(collectionName)
          .orderBy('creationDate', descending: true)
          .orderBy('name')
          .get();
      if (docs.docs.isEmpty) {
        return [];
      }
      final List<Clipboard> clipboards = [];
      for (final doc in docs.docs) {
        if (doc.data() != null) {
          clipboards.add(Clipboard.fromJson(doc.data(), doc.id));
        }
      }
      return clipboards;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
      await CMImage.deleteAllImagesFromFolder('clipboards/$id');
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
