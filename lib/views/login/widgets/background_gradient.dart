import 'package:campus_motorsport/services/color_services.dart';
import 'package:flutter/material.dart';



/// Gradient background, should be the same gradient as used for the splash screen.
class BackgroundGradient extends StatelessWidget {
  final Widget? child;
  final bool? drawGradient;

  BackgroundGradient({this.child, this.drawGradient, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: (drawGradient ?? true)? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            ColorServices.brighten(Theme.of(context).colorScheme.surface, 25),
            Theme.of(context).colorScheme.surface,
          ],
        ) : null,
      ),
      child: child,
    );
  }
}
