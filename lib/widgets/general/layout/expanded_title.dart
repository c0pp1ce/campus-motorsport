import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

/// A title layout for the expanded appbar layout.
class ExpandedTitle extends StatelessWidget {
  const ExpandedTitle({
    required this.title,
    this.margin = const EdgeInsets.only(bottom: SizeConfig.basePadding),
    Key? key,
  }) : super(key: key);

  final String title;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: double.infinity,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
