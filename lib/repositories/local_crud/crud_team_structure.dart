import 'dart:io';

import 'package:campus_motorsport/models/team_structure.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_team_structure.dart'
    as firestore;
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Should mostly work with dynamic storagePath values if they are required. Just
/// replace the static path where needed.
class CrudTeamStructure {
  CrudTeamStructure() {
    try {
      dirPath = getApplicationDocumentsDirectory().then((value) => value.path);
    } on MissingPlatformDirectoryException {
      dirPath = '' as Future<String>;
    }
  }

  late Future<String> dirPath;
  Box? hiveBox;

  /// Determined based on name, which is acquired from the original file name.
  Future<bool> needsUpdate(String fbName) async {
    if (fbName.isEmpty) {
      return false;
    }
    try {
      final String path = await dirPath;
      if (path.isEmpty) {
        return false;
      }
      final TeamStructure? ts = await getMostRecent();
      if (ts == null) {
        return true;
      } else {
        return ts.name != fbName;
      }
    } on Exception {
      return false;
    }
  }

  /// Returns the teamsStructure with ID most-recent.
  Future<TeamStructure?> getMostRecent() async {
    try {
      final String path = await dirPath;
      if (path.isEmpty) {
        return null;
      }
      hiveBox ??= await Hive.openBox('local-storage');

      Map<dynamic, dynamic>? data = (await hiveBox!.get('team-structure')
          as Map<dynamic, dynamic>?)?[firestore.CrudTeamStructure.id];
      if (data == null) {
        return null;
      }
      data = data.cast<String, dynamic>();
      final TeamStructure ts = TeamStructure.fromJson(
        data as Map<String, dynamic>,
        data['id'],
      );
      ts.localFilePath = await _getFilePath(TeamStructure.storagePath);
      return ts;
    } on Exception {
      return null;
    }
  }

  /// Sets the teamsStructure with ID most-recent.
  Future<bool> setMostRecent(TeamStructure? ts) async {
    try {
      final bool oldVersionDeleted = await deleteMostRecent();
      if (!oldVersionDeleted) {
        print('Could not delete old version.');
        return false;
      }
      if (ts == null) {
        /// New value is null, only delete of local version needed.
        return true;
      }
      final String path = await dirPath;
      if (path.isEmpty) {
        return false;
      }
      hiveBox ??= await Hive.openBox('local-storage');

      final bool fileSaved = await _saveFile(ts);
      if (!fileSaved) {
        return false;
      }

      await hiveBox!.put('team-structure', {
        firestore.CrudTeamStructure.id: ts.toJson(true),
      });

      return true;
    } on Exception {
      return false;
    }
  }

  /// Deletes the teamsStructure with ID most-recent.
  Future<bool> deleteMostRecent() async {
    try {
      final String path = await dirPath;
      if (path.isEmpty) {
        return false;
      }
      hiveBox ??= await Hive.openBox('local-storage');

      final TeamStructure? ts = await getMostRecent();
      if (ts == null) {
        return true;
      }

      final bool fileDeleted = await _deleteFile(TeamStructure.storagePath);
      if (!fileDeleted) {
        print('could not delete file');
        return false;
      }

      await hiveBox!.put('team-structure', {
        firestore.CrudTeamStructure.id: null,
      });
      return true;
    } on Exception {
      return false;
    }
  }

  /// Saving of a network image based on
  /// https://stackoverflow.com/questions/59894880/how-to-get-a-uint8list-from-a-network-image-by-url-in-flutter
  Future<bool> _saveFile(TeamStructure ts) async {
    if (ts.url == null) {
      return false;
    }
    try {
      final File file = File(await _getFilePath(TeamStructure.storagePath));

      /// Need to get the bytes.
      final http.Response response = await http.get(
        Uri.parse(ts.url!),
      );
      final bytes = response.bodyBytes;
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(bytes, flush: true);
      return true;
    } on Exception catch (e) {
      print(e);
      print('Save file to local storage failed.');
      return false;
    }
  }

  Future<bool> _deleteFile(String storagePath) async {
    try {
      final File file = File(await _getFilePath(storagePath));
      await file.delete();
      return true;
    } on Exception {
      print('Could not delete image $storagePath');
      return false;
    }
  }

  /// Does not check if [dirPath] is valid.
  Future<String> _getFilePath(String storagePath) async {
    return '${await dirPath}/$storagePath';
  }
}
