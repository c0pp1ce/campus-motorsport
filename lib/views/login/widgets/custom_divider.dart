import 'package:flutter/material.dart';

/// A custom divider to split up login section from the register button.
class CustomDivider extends StatelessWidget {

  CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _divider(context),
          ),
          _verticalSpacing(),
          Text(
            'oder',
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          _verticalSpacing(),
          Expanded(
            child: _divider(context),
          ),
        ],
      ),
    );
  }

  Divider _divider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      indent: 0,
      endIndent: 0,
      thickness: 0.7,
    );
  }

  SizedBox _verticalSpacing() {
    return SizedBox(
      width: 8.0,
    );
  }
}