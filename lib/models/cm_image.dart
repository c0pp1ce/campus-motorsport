// ignore_for_file: prefer_initializing_formals
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<bool> uploadImageToFirebaseStorage() async {
    if (imageProvider is NetworkImage ||
        imageProvider == null ||
        path == null) {
      return false;
    }
    try {
      /// Get current users id.
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'NO-ID';

      /// File name is a mix of user id and upload time.
      final Reference reference =
          FirebaseStorage.instance.ref().child('images/$uid-${DateTime.now()}');

      /// Upload the image
      final TaskSnapshot taskSnapshot = await reference.putFile(File(path!));

      /// Check success
      if (taskSnapshot.state != TaskState.success) {
        return false;
      }

      /// Retrieve and save url
      await taskSnapshot.ref.getDownloadURL().then((value) {
        url = value;
      });
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
