import 'package:flutter/material.dart';

/// The right view of the stacked UI.
///
/// Recommended to be used as a context-sensitive menu.
/// In order to connect this view to the [MainView] a state management solution
/// like Provider or BloC is recommended.
class ContextDrawer extends StatelessWidget {
  /// The content of this [ContextDrawer].
  final Widget? child;

  const ContextDrawer({this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(
          /// The width occupied by the inactive [MainView] plus the margin between
          /// it and the [ContextDrawer] content.
          width: 55,
        ),
        Expanded(
          child: _buildContext(context),
        ),
      ],
    );
  }

  /// Places the [child] in a predefined [Container] with maximum available
  /// height and width.
  Widget _buildContext(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        margin: const EdgeInsets.only(right: 5.0),
        padding: const EdgeInsets.all(10.0),
        /// Should be the same as used in the other [StackedUI] widgets.
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