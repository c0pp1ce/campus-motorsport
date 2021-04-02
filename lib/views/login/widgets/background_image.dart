import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

/// Displays the [image] if given, or a transparent image.
class BackgroundImage extends StatelessWidget {
  final Widget? child;
  final ImageProvider? image;

  BackgroundImage({this.child, this.image, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image ?? MemoryImage(kTransparentImage),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
