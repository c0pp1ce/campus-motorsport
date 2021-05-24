import 'package:flutter/material.dart';

/// A reusable card with predefined content padding and color.
class SimpleCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  SimpleCard(
      {required this.child,
        this.elevation = 5.0,
        this.color,
        this.shadowColor,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color ?? Theme.of(context).colorScheme.surface,
      margin: EdgeInsets.zero,
      shadowColor: shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}