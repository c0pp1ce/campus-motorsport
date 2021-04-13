import 'package:flutter/material.dart';

/// A reusable card with predefined content padding and color.
class SimpleCard extends StatelessWidget {
  final Widget child;
  final double elevation;

  SimpleCard({required this.child, this.elevation = 5.0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
