import 'package:campus_motorsport/models/training_ground.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_training_grounds.dart';
import 'package:campus_motorsport/repositories/local_crud/crud_training_grounds.dart'
    as local;

/// This provider handles getting & providing [TrainingGround] and [TeamStructure] from Fire-
/// base or local storage ass well as updating the local storage when needed.
///
/// Updates local storage after any firebase operations because the crud operations
/// use DateTime.now() to update their lastUpdate attribute thus the other way round
/// could lead to unneeded updates to local storage.
class OfflineInformationProvider extends BaseProvider {
  OfflineInformationProvider({
    required this.offlineMode,
  })  : _crudTrainingGroundsLocal = local.CrudTrainingGrounds(),
        _crudTrainingGroundsFirebase = CrudTrainingGrounds(),
        super();

  final bool offlineMode;
  final local.CrudTrainingGrounds _crudTrainingGroundsLocal;
  final CrudTrainingGrounds _crudTrainingGroundsFirebase;

  List<TrainingGround>? _trainingGrounds;

  Future<void> updateTrainingGrounds([
    bool notifyListeners = true,
  ]) async {
    /// Get from local storage if no update wanted.
    if (offlineMode) {
      _trainingGrounds = await _crudTrainingGroundsLocal.getAll() ?? [];
      if (notifyListeners) {
        notify();
      }
      return;
    } else {
      /// Online mode, Check if Firebase contains newer version.
      if (await _crudTrainingGroundsLocal
          .needsUpdate(await _crudTrainingGroundsFirebase.getLastUpdate())) {
        /// Get the most recent version and save it locally.
        _trainingGrounds = await _crudTrainingGroundsFirebase.getAll() ?? [];
        await _crudTrainingGroundsLocal.saveAll(_trainingGrounds!);
      } else {
        /// Newest version is locally available.
        _trainingGrounds = await _crudTrainingGroundsLocal.getAll() ?? [];
      }
    }
    if (notifyListeners) {
      notify();
    }
  }

  Future<bool> removeTrainingGround(TrainingGround trainingGround) async {
    final bool removedFromRemote = await _crudTrainingGroundsFirebase.delete(
      trainingGround.id,
      trainingGround.storagePath,
    );
    if (!removedFromRemote) {
      return false;
    }

    final bool locallyRemoved = await _crudTrainingGroundsLocal.delete(
      trainingGround.id,
      trainingGround.storagePath,
    );
    if (!locallyRemoved) {
      print('Couldnt delete ${trainingGround.id} locally.');
    }

    await updateTrainingGrounds(true);
    return true;
  }

  List<TrainingGround> get trainingGrounds {
    if (_trainingGrounds == null) {
      updateTrainingGrounds();
      return [];
    }
    return _trainingGrounds!;
  }
}
