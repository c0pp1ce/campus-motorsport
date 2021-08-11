// ignore_for_file: prefer_initializing_formals
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

/// Simple wrapper class used for image picker and displaying images.
class CMImage {
  CMImage();

  CMImage.fromBytes(Uint8List bytes, String path) : path = path {
    imageProvider = MemoryImage(bytes);
  }

  CMImage.fromUrl(String url) : url = url {
    imageProvider = NetworkImage(url);
  }

  ImageProvider? imageProvider;
  String? url;
  String? path;

  CMImage? cloneNetworkImage() {
    if (imageProvider is NetworkImage) {
      return CMImage.fromUrl(url!);
    }
  }

  /// Recursively deletes any image in this folder and any subfolder.
  ///
  /// On default, it only deletes the files from the given folder as well as any
  /// direct subfolder. Adjust [depth] to change this behaviour.
  static Future<bool> deleteAllImagesFromFolder(String folder,
      [int depth = 1]) async {
    try {
      final files =
          await FirebaseStorage.instance.ref('images/$folder').listAll();
      for (final file in files.items) {
        await file.delete();
      }
      if (depth > 0) {
        for (final prefix in files.prefixes) {
          await CMImage.deleteAllImagesFromFolder(
            '$folder/${prefix.name}',
            depth - 1,
          );
        }
      }
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteFromFirebase() async {
    if (url == null) {
      return false;
    }

    try {
      await FirebaseStorage.instance.refFromURL(url!).delete();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> uploadImageToFirebaseStorage(String folder) async {
    if (imageProvider is NetworkImage ||
        imageProvider == null ||
        path == null) {
      print('image upload not needed');
      return false;
    }
    try {
      /// Get current users id.
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'NO-ID';

      /// File name is a mix of user id and upload time.
      final format = DateFormat('yyyy-MM-dd-hh-mm');
      final Reference reference = FirebaseStorage.instance
          .ref()
          .child('images/$folder/$uid-${format.format(DateTime.now())}');

      /// Upload the image
      final TaskSnapshot taskSnapshot = await reference.putFile(
        File(path!),
      );

      /// Check success
      if (taskSnapshot.state != TaskState.success) {
        return false;
      }

      /// Retrieve and save url
      await taskSnapshot.ref.getDownloadURL().then((value) {
        url = value;
      });
      final File tmpFile = File(path!);
      await tmpFile.delete();
      path = null;
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
