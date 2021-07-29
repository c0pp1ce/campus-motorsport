import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Create, read, update, delete CContainer (vehicles, stocks).
class CrudCompContainer {
  CrudCompContainer() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<bool> createContainer({
    required ComponentContainer componentContainer,
  }) async {
    try {
      await _firestore.collection('component-containers').add(
            await componentContainer.toJson(),
          );
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<ComponentContainer?> getContainer(String docId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> containerData =
          await _firestore.collection('component-containers').doc(docId).get();
      if (containerData.data() == null) {
        return null;
      }
      return ComponentContainer.fromJson(containerData.data()!, docId);
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<ComponentContainer>?> getContainers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> documents =
          await _firestore.collection('component-containers').get();

      final List<ComponentContainer> containers = List.empty(growable: true);
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in documents.docs) {
        containers.add(
          ComponentContainer.fromJson(doc.data(), doc.id),
        );
      }
      return containers;
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Used to update everything except updates field.
  Future<bool> updateContainer({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('component-containers')
          .doc(docId)
          .update(data);
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Adds the given update to the updates array of the container.
  Future<bool> addUpdate(
      {required String docId, required Update update}) async {
    try {
      await _firestore.collection('component-containers').doc(docId).update({
        'updates': FieldValue.arrayUnion([update.toJson()]),
      });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteContainer(String docId) async {
    try {
      await _firestore.collection('component-containers').doc(docId).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
