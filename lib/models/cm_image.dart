// ignore_for_file: prefer_initializing_formals
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Simple wrapper class used for image picker and displaying images.
class CMImage {
  CMImage();

  CMImage.fromBytes(Uint8List bytes) {
    imageProvider = Image.memory(bytes).image;
  }

  CMImage.fromUrl(String url) : url = url {
    imageProvider = Image.network(url).image;
  }

  ImageProvider? imageProvider;
  String? url;
}
