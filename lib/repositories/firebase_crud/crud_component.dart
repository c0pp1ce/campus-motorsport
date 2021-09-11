import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Create, Read, Update, Delete vehicle components in firebase.
class CrudComponent {
  CrudComponent() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Creates a new entry in the components collection. Adds an id to the given
  /// component.
  Future<bool> createComponent({
    required BaseComponent component,
  }) async {
    try {
      /// Create the new part.
      final DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('components').doc().get();
      component.id = document.id;
      await _firestore.collection('components').doc(document.id).set(
            await component.toJson(),
          );

      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<BaseComponent?> getComponent(String docId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> componentData =
          await _firestore.collection('components').doc(docId).get();
      if (componentData.data() == null) {
        return null;
      }
      if (componentData.data()!.containsKey('additionalData')) {
        return ExtendedComponent.fromJson(componentData.data()!, docId);
      } else {
        return BaseComponent.fromJson(componentData.data()!, docId);
      }
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<BaseComponent>?> getComponents() async {
    try {
      /// Get all documents of the collection.
      final QuerySnapshot<Map<String, dynamic>> result = await _firestore
          .collection('components')
          .orderBy('category')
          .orderBy('name')
          .get();

      /// Fill the list.
      final List<BaseComponent> resultList = List.empty(growable: true);
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in result.docs) {
        if (doc.data().containsKey('additionalData')) {
          resultList.add(ExtendedComponent.fromJson(doc.data(), doc.id));
        } else {
          resultList.add(BaseComponent.fromJson(doc.data(), doc.id));
        }
      }

      return resultList;
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Deletes the component from the components collection as well as removing it
  /// from any vehicle/storage component list and current-state.
  Future<bool> deleteComponent(BaseComponent component) async {
    try {
      return _firestore.runTransaction((transaction) async {
        /// Get the component doc.
        final DocumentReference componentDoc =
            _firestore.collection('components').doc(component.id);
        final DocumentSnapshot componentSnapshot =
            await transaction.get(componentDoc);

        /// Get the most recent data.
        final Object? data = componentSnapshot.data();
        if (data != null) {
          final BaseComponent _component = BaseComponent.fromJson(
            data as Map<String, dynamic>,
            componentDoc.id,
          );

          /// Delete component from vehicles/storages.
          if (_component.usedBy?.isNotEmpty ?? false) {
            final CrudCompContainer crudCompContainer = CrudCompContainer();

            for (final id in _component.usedBy!) {
              await crudCompContainer.deleteComponent(
                docId: id,
                componentId: _component.id,
                fromUpdates: true,
              );
            }
          }

          /// Delete component doc
          transaction.delete(componentDoc);
          return true;
        } else {
          return false;
        }
      });
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
