import 'package:flutter/material.dart';

class CMLabel extends StatelessWidget {
  const CMLabel({
    required this.label,
    Key? key,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            fontSize: 16,
          ),
    );
  }
}
