import 'package:flutter/material.dart';

/// Displays the [image] if given, or a transparent image.
class BackgroundImage extends StatelessWidget {
  final Widget? child;
  final ImageProvider image;

  const BackgroundImage({
    this.child,
    required this.image,
    Key? key,
  }) : super(key: key);

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
