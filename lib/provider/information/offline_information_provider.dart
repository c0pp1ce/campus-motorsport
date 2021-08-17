import 'package:campus_motorsport/models/team_structure.dart';
import 'package:campus_motorsport/models/training_ground.dart';
import 'package:campus_motorsport/provider/base_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_team_structure.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_training_grounds.dart';
import 'package:campus_motorsport/repositories/local_crud/crud_training_grounds.dart'
    as local;
import 'package:campus_motorsport/repositories/local_crud/crud_team_structure.dart'
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
  final local.CrudTeamStructure _crudTeamStructureLocal =
      local.CrudTeamStructure();
  final CrudTeamStructure _crudTeamStructureFirebase = CrudTeamStructure();

  List<TrainingGround>? _trainingGrounds;
  TeamStructure? _teamStructure;

  bool alreadyRequestedUpdate = false;

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

  /// Gets the team structure and updates local version if needed.
  ///
  /// The used pdf viewers read files, it therefore is crucial that the teamStructure
  /// is always locally saved before returning from this method.
  Future<void> getTeamStructure() async {
    _teamStructure = await _crudTeamStructureLocal.getMostRecent();
    if (!offlineMode) {
      final TeamStructure? firebaseTs = await _crudTeamStructureFirebase.get();
      if ((firebaseTs == null && _teamStructure != null) ||
          await _crudTeamStructureLocal.needsUpdate(firebaseTs?.name ?? '')) {
        await _crudTeamStructureLocal.setMostRecent(firebaseTs);
        _teamStructure = await _crudTeamStructureLocal.getMostRecent();
      }
    }
    notify();
  }

  Future<bool> setTeamStructure(String path) async {
    final String fileName = path.split('/').last;
    final String displayName = fileName.split('.').first;
    // final String storagePath = 'files/team-structure/$fileName';
    final ts = TeamStructure(
      name: displayName,
      id: CrudTeamStructure.id,
      localFilePath: path, // Will be changed once the local storage is updated.
    );
    final bool uploaded = await _crudTeamStructureFirebase.setTeamStructure(ts);
    if (!uploaded) {
      return false;
    }
    await getTeamStructure();
    notify();
    return true;
  }

  Future<bool> deleteTeamStructure() async {
    if (_teamStructure == null) {
      return false;
    }
    final bool deleted =
        await _crudTeamStructureFirebase.delete(_teamStructure!);
    if (!deleted) {
      return false;
    }
    await getTeamStructure();
    notify();
    return true;
  }

  List<TrainingGround> get trainingGrounds {
    if (_trainingGrounds == null) {
      updateTrainingGrounds();
      return [];
    }
    return _trainingGrounds!;
  }

  TeamStructure? get teamStructure {
    if (_teamStructure == null && !alreadyRequestedUpdate) {
      alreadyRequestedUpdate = true;
      getTeamStructure();
    }
    return _teamStructure;
  }
}
