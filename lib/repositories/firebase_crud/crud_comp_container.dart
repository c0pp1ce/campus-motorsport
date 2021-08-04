import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/component_containers/event.dart';
import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';
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
      final QuerySnapshot<Map<String, dynamic>> documents = await _firestore
          .collection('component-containers')
          .orderBy('type')
          .orderBy('name')
          .get();

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

  /// Used to update everything except updates and components field.
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

  /// Adds the given event to the vehicle and updates the counters on each current-state
  /// update which has a counter set.
  ///
  /// Updates the current-state if any of those updates reaches 0 with this event.
  Future<bool> addEvent({
    required String docId,
    required Event event,
  }) async {
    try {
      return _firestore.runTransaction((transaction) async {
        /// Get the document.
        final DocumentReference containerDoc =
            _firestore.collection('component-containers').doc(docId);
        final DocumentSnapshot containerSnapshot =
            await transaction.get(containerDoc);

        if (containerSnapshot.data() == null) {
          return false;
        }

        final Map<String, dynamic> data =
            containerSnapshot.data()! as Map<String, dynamic>;

        /// Find all updates in current-state with a counter.
        final List<Map<String, dynamic>> updatesWithCounter = [];
        for (final update in (data['current-state'] as List? ?? [])
            .cast<Map<String, dynamic>>()) {
          if (update['eventCounter'] != null) {
            updatesWithCounter.add(update);
          }
        }

        final List<Map<String, dynamic>> onlyCounterUpdatesNeeded = [];
        final List<Map<String, dynamic>> counterReachedZero = [];

        /// Calculate new counters.
        /// If counter reaches zero get the original component as that is needed
        /// to determine if the counter needs to be reset or removed.
        for (final update in updatesWithCounter) {
          int newCounter =
              (update['eventCounter'] as int) - event.decrementCounterBy;
          if (newCounter <= 0) {
            /// Decrement the state of the component.
            int stateIndex = ComponentStates.values.indexOf(
                (update['component'] as Map<String, dynamic>)['state']);
            stateIndex = stateIndex - 1;
            if (stateIndex < 0) {
              stateIndex = 0;
            }
            (update['component'] as Map<String, dynamic>)['state'] =
                ComponentStates.values[stateIndex];

            /// Get original component and Reset the counter.
            final BaseComponent? baseComponent =
                await CrudComponent().getComponent(
              (update['component'] as Map<String, dynamic>)['id'],
            );
            if (baseComponent == null) {
              throw Exception(
                  'Could not get the original component for $update');
            }
            if (baseComponent.baseEventCounter == null) {
              /// No base counter aka no reset possible.
              update.remove('eventCounter');
            } else {
              /// Make sure to not end up in an endless loop.
              if (baseComponent.baseEventCounter! < 1) {
                baseComponent.baseEventCounter = 1;
              }

              /// Calculate new counter.
              newCounter = newCounter + baseComponent.baseEventCounter!;

              /// Possibly multiple state changes needed.
              /// Attention : Currently only 3 states possible, so the second decrement
              /// and everyone after will lead to the same state.
              while (newCounter <= 0) {
                (update['component'] as Map<String, dynamic>)['state'] =
                    ComponentStates.bad;
                newCounter = newCounter + baseComponent.baseEventCounter!;
              }

              /// Update counter.
              update['eventCounter'] = newCounter;
            }
            counterReachedZero.add(update);
          } else {
            update['eventCounter'] = newCounter;
            onlyCounterUpdatesNeeded.add(update);
          }
        }

        /// Update counter without further side effect.
        /// Changes the counter of updates in current-state but does not do anything
        /// else.
        await addUpdates(
          docId: docId,
          updates: [],
          updatesListMap: onlyCounterUpdatesNeeded,
          fromListMap: true,
          addToCurrentStateOnly: true,
        );

        /// No need to get new snapshot here since one update cannot be in both
        /// lists at the same time.

        /// Update components where the counter reached 0. Decrements state by 1
        /// and adds a an update to current-state and updates list.
        await addUpdates(
          docId: docId,
          updates: [],
          updatesListMap: counterReachedZero,
          fromListMap: true,
        );

        /// Add the event to the events list.
        transaction.update(containerDoc, {
          'events': FieldValue.arrayUnion([event.toJson()]),
        });
        return true;
      });
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Adds the given updates to the updates array of the container, if [addToCurrentStateOnly] is not true.
  /// Updates current-state as well.
  Future<bool> addUpdates({
    required String docId,
    required List<Update> updates,
    List<Map<String, dynamic>>? updatesListMap,
    bool fromListMap = false,
    bool addToCurrentStateOnly = false,
    DocumentReference? document,
    DocumentSnapshot? snapshot,
  }) async {
    assert(snapshot != null && document != null ||
        snapshot == null && document == null);
    assert(fromListMap && updatesListMap != null || !fromListMap);

    /// No updates given.
    if (updates.isEmpty && !fromListMap) {
      return true;
    }
    try {
      late final List<Map<String, dynamic>> data;
      if (fromListMap) {
        data = updatesListMap!;
      } else {
        data = [];
        for (final update in updates) {
          data.add(await update.toJson());
        }
      }

      return _firestore.runTransaction((transaction) async {
        /// Get the document.
        final DocumentReference containerDoc = document ??
            _firestore.collection('component-containers').doc(docId);
        final DocumentSnapshot containerSnapshot =
            snapshot ?? await transaction.get(containerDoc);

        if (containerSnapshot.data() == null) {
          return false;
        }

        /// Delete the current updates which shall be replaced.
        for (final update in updates) {
          if (update.component.id == null) {
            continue;
          }
          await deleteComponentFromCurrentState(
            docId: docId,
            componentId: update.component.id!,
            document: containerDoc,
            snapshot: containerSnapshot,
          );
        }

        /// Add the new updates to the current state and updates list.
        transaction.update(containerDoc, {
          'current-state': FieldValue.arrayUnion(data),
          if (!addToCurrentStateOnly) 'updates': FieldValue.arrayUnion(data),
        });
        return true;
      });
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Adds the given components to the container and updates the components usedBy
  /// list.
  Future<bool> addComponents({
    required String docId,
    required List<String> data,
  }) async {
    if (data.isEmpty) {
      return true;
    }
    try {
      _firestore.runTransaction((transaction) async {
        /// Update component container.
        transaction.update(
          _firestore.collection('component-containers').doc(docId),
          {
            'components': FieldValue.arrayUnion(data),
          },
        );

        /// Update each added component.
        for (final id in data) {
          transaction.update(
            _firestore.collection('components').doc(id),
            {
              'usedBy': FieldValue.arrayUnion([docId]),
            },
          );
        }
      });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Deletes the component as well as the corresponding entry inside the
  /// current-state array as well as every occurrence in the updates entry.
  Future<bool> deleteComponent({
    required String docId,
    required String componentId,
  }) async {
    try {
      return _firestore.runTransaction((transaction) async {
        /// Get the document.
        final DocumentReference containerDoc =
            _firestore.collection('component-containers').doc(docId);
        final DocumentSnapshot containerSnapshot =
            await transaction.get(containerDoc);

        if (containerSnapshot.data() == null) {
          return false;
        }

        await deleteComponentFromCurrentState(
          docId: docId,
          componentId: componentId,
          document: containerDoc,
          snapshot: containerSnapshot,
        );

        await deleteComponentFromUpdates(
          docId: docId,
          componentId: componentId,
          document: containerDoc,
          snapshot: containerSnapshot,
        );

        transaction.update(containerDoc, {
          'components': FieldValue.arrayRemove([componentId]),
        });
        return true;
      });
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// Tries to delete the update entry of the given component from the
  /// current-state array (if found).
  /// Also returns true when there is no matching entry.
  Future<bool> deleteComponentFromCurrentState({
    required String docId,
    required String componentId,
    DocumentSnapshot? snapshot,
    DocumentReference? document,
  }) async {
    assert(snapshot != null && document != null ||
        snapshot == null && document == null);
    try {
      return _firestore.runTransaction((transaction) async {
        /// Get the document.
        final DocumentReference containerDoc = document ??
            _firestore.collection('component-containers').doc(docId);
        final DocumentSnapshot containerSnapshot =
            snapshot ?? await transaction.get(containerDoc);

        if (containerSnapshot.data() == null) {
          return false;
        }

        final Map<String, dynamic> data =
            containerSnapshot.data()! as Map<String, dynamic>;

        bool componentFound = false;
        Map<String, dynamic>? matchingUpdate;
        for (final update in (data['current-state'] as List? ?? [])
            .cast<Map<String, dynamic>>()) {
          if ((update['component'] as Map<String, dynamic>?)?['id'] ==
              componentId) {
            componentFound = true;
            matchingUpdate = update;
            break;
          }
        }

        if (componentFound) {
          transaction.update(containerDoc, {
            'current-state': FieldValue.arrayRemove([matchingUpdate!]),
          });
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

  Future<bool> deleteComponentFromUpdates({
    required String docId,
    required String componentId,
    DocumentSnapshot? snapshot,
    DocumentReference? document,
  }) async {
    assert(snapshot != null && document != null ||
        snapshot == null && document == null);
    try {
      return _firestore.runTransaction((transaction) async {
        /// Get the document.
        final DocumentReference containerDoc = document ??
            _firestore.collection('component-containers').doc(docId);
        final DocumentSnapshot containerSnapshot =
            snapshot ?? await transaction.get(containerDoc);

        if (containerSnapshot.data() == null) {
          return false;
        }

        final Map<String, dynamic> data =
            containerSnapshot.data()! as Map<String, dynamic>;

        bool componentFound = false;
        final List<Map<String, dynamic>> matchingUpdates = [];
        for (final update
            in (data['updates'] as List? ?? []).cast<Map<String, dynamic>>()) {
          if ((update['component'] as Map<String, dynamic>?)?['id'] ==
              componentId) {
            componentFound = true;
            matchingUpdates.add(update);
          }
        }

        if (componentFound) {
          transaction.update(containerDoc, {
            'updates': FieldValue.arrayRemove(matchingUpdates),
          });
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
