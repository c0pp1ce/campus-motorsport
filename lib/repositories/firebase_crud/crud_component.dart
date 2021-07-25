import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Create, Read, Update, Delete vehicle components in firebase.
class CrudComponent {
  CrudComponent() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Creates a new entry in the components collection.
  Future<bool> createComponent({
    required BaseComponent component,
  }) async {
    try {
      /// Create the new part.
      //final DocumentReference doc =
      await _firestore.collection('components').add(
            component.toJson(),
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
        return ExtendedComponent.fromJson(componentData.data()!);
      } else {
        return BaseComponent.fromJson(componentData.data()!);
      }
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<BaseComponent>?> getComponents() async {
    try {
      /// Get all documents of the collection.
      final QuerySnapshot<Map<String, dynamic>> result =
          await _firestore.collection('components').get();

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
  /// from any vehicle/storage component list.
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
          final BaseComponent component = BaseComponent.fromJson(
            data as Map<String, dynamic>,
          );

          /// Delete component from vehicles/storages.
          if (component.usedBy?.isNotEmpty ?? false) {
            // TODO : For each id get vehicle doc
            // TODO : The for each doc delete component from it
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
