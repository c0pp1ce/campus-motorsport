import 'package:flutter/material.dart';

/// Displays the [image] if given, or a transparent image.
class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    this.child,
    required this.image,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (child != null) child!
      ],
    );
  }
}
