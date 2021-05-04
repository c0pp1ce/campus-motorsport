import 'package:flutter/material.dart';

/// The right view of the stacked UI.
///
/// Designed be used as a context-sensitive menu.
class ContextDrawer extends StatelessWidget {
  final Widget? child;

  ContextDrawer({this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(
          width: 55,
        ),
        Expanded(
          child: _buildContext(context),
        ),
      ],
    );
  }

  Widget _buildContext(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        margin: const EdgeInsets.only(right: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: const Radius.circular(15.0),
          ),
          color: ElevationOverlay.applyOverlay(
              context, Theme.of(context).colorScheme.surface, 5),
        ),
        child: child,
      ),
    );
  }
}
