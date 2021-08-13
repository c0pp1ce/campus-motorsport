import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/training_ground.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

/// Method for locally storing [TrainingGround].
///
/// Only create, read and delete is implemented.
/// Stores the image as a file and a json entry inside of the [Hive] db.
class CrudTrainingGrounds {
  CrudTrainingGrounds() {
    try {
      dirPath = getApplicationDocumentsDirectory().then((value) => value.path);
    } on MissingPlatformDirectoryException {
      dirPath = '' as Future<String>;
    }
  }

  late Future<String> dirPath;
  Box? hiveBox;

  /// Checks the first entry and compares the given date to lastUpdate of it.
  ///
  /// The lastUpdate attribute is stored inside of a meta collection in firebase
  /// and its value is assigned to every object. In that sense, lastUpdate re-
  /// presents the most recent date where any entry of the collection has been updated.
  Future<bool> needsUpdate(DateTime givenDate) async {
    try {
      final String path = await dirPath;
      if (path.isEmpty) {
        return false;
      }
      hiveBox ??= await Hive.openBox<Map<String, dynamic>>('local-storage');

      final DateTime lastUpdate = ((await hiveBox!.get('meta-info')
                  as Map<String, dynamic>)['training-grounds']
              as Map<String, dynamic>)['lastUpdate'] ??
          DateTime.utc(1900);

      if (lastUpdate.isBefore(givenDate)) {
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  Future<List<TrainingGround>?> getAll() async {
    final String path = await dirPath;
    if (path.isEmpty) {
      return null;
    }
    hiveBox ??= await Hive.openBox<Map<String, dynamic>>('local-storage');

    final DateTime lastUpdate = ((await hiveBox!.get('meta-info')
                as Map<String, dynamic>)['training-grounds']
            as Map<String, dynamic>)['lastUpdate'] ??
        DateTime.utc(1900);

    /// Gets maps from hive.
    final List<Map<String, dynamic>>? maps =
        await hiveBox!.get('training-grounds');
    if (maps?.isEmpty ?? true) {
      return null;
    }
    final List<TrainingGround> trainingGrounds = List.empty(growable: true);
    for (final json in maps!) {
      /// Get locally stored file.
      final CMImage? image = await _getImage(json['storagePath']);
      if (image == null) {
        continue;
      }
      trainingGrounds.add(
        TrainingGround.fromJson(
          json,
          lastUpdate,
          json['id'],
          image: image,
        ),
      );
    }
    return trainingGrounds;
  }

  Future<bool> saveAll(List<TrainingGround> trainingGrounds) async {
    final String path = await dirPath;
    if (path.isEmpty) {
      return false;
    }
    hiveBox ??= await Hive.openBox<Map<String, dynamic>>('local-storage');

    /// Check if the data actually changed.
    final List<Map<String, dynamic>>? maps =
        await hiveBox!.get('training-grounds');
    late final List<TrainingGround> notStoredYet;
    if (maps?.isNotEmpty ?? false) {
      notStoredYet = [];
      for (final tg in trainingGrounds) {
        bool alreadyStored = false;
        for (final json in maps!) {
          if (json['id'] == tg.id &&
              json['name'] == tg.name &&
              json['storagePath'] == tg.storagePath) {
            alreadyStored = true;
            break;
          }
        }
        if (!alreadyStored) {
          notStoredYet.add(tg);
        }
      }
    } else {
      notStoredYet = trainingGrounds;
    }

    final List<Map<String, dynamic>> data = maps ?? [];

    /// Save data
    for (final tg in notStoredYet) {
      final bool imageSaved = await _saveImage(tg.image, tg.storagePath);
      if (!imageSaved) {
        print('image save failed. ${tg.name}');
        continue;
      } else {
        data.add(tg.toJson());
      }
    }
    await hiveBox!.put('training-grounds', data);
    await _updateMetaInfo(DateTime.now());
    return true;
  }

  Future<bool> delete(String id, String storagePath) async {
    final String path = await dirPath;
    if (path.isEmpty) {
      return false;
    }
    hiveBox ??= await Hive.openBox<Map<String, dynamic>>('local-storage');

    /// Delete file.
    if (!(await _deleteImage(storagePath))) {
      return false;
    }

    /// Delete from hive.
    final List<Map<String, dynamic>>? tgList =
        await hiveBox!.get('training-grounds');
    if (tgList?.isEmpty ?? true) {
      return false;
    }
    tgList!.removeWhere((element) =>
        element['id'] == id && element['storagePath'] == storagePath);
    await hiveBox!.put('training-grounds', tgList);
    await _updateMetaInfo(DateTime.now());
    return true;
  }

  Future<bool> _updateMetaInfo(DateTime date) async {
    final String path = await dirPath;
    if (path.isEmpty) {
      return false;
    }
    hiveBox ??= await Hive.openBox<Map<String, dynamic>>('local-storage');

    try {
      await hiveBox!.put('meta-info', {
        'training-grounds': {
          'lastUpdate': date.toUtc(),
        },
      });
      return true;
    } on Exception {
      return false;
    }
  }

  Future<CMImage?> _getImage(String storagePath) async {
    try {
      final File file = File(await _getFilePath(storagePath));
      return CMImage.fromBytes(
        await file.readAsBytes(),
        file.path,
        neverUpload: true,
      );
    } on Exception {
      print('Read image from local storage failed.');
      return null;
    }
  }

  /// Saving of a network image based on accepted answer of
  /// https://stackoverflow.com/questions/59894880/how-to-get-a-uint8list-from-a-network-image-by-url-in-flutter
  Future<bool> _saveImage(CMImage image, String storagePath) async {
    if (image.imageProvider == null) {
      return false;
    }
    try {
      final File file = File(await _getFilePath(storagePath));

      /// Need to get the bytes.
      late Uint8List bytes;
      if (image.imageProvider is MemoryImage) {
        bytes = (image.imageProvider! as MemoryImage).bytes;
      } else {
        assert(image.imageProvider is NetworkImage);
        await (image.imageProvider! as NetworkImage)
            .obtainKey(ImageConfiguration())
            .then((key) {
          (image.imageProvider! as NetworkImage).load(key,
              (Uint8List imageBytes,
                  {bool allowUpscaling = false,
                  int? cacheWidth,
                  int? cacheHeight}) {
            bytes = imageBytes.buffer.asUint8List();
            return instantiateImageCodec(imageBytes);
          });
        });
      }
      await file.writeAsBytes(bytes, flush: true);
      return true;
    } on Exception {
      print('Save image to local storage failed.');
      return false;
    }
  }

  Future<bool> _deleteImage(String storagePath) async {
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
