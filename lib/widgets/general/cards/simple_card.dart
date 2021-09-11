import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

/// A reusable card with predefined content padding and color.
class SimpleCard extends StatelessWidget {
  const SimpleCard({
    required this.child,
    this.elevation = SizeConfig.baseBackgroundElevation,
    this.color,
    this.shadowColor,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(SizeConfig.basePadding),
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color ?? Theme.of(context).colorScheme.surface,
      margin: margin,
      shadowColor: shadowColor,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
