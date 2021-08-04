import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

/// The right view of the stacked UI.
///
/// Recommended to be used as a context-sensitive menu.
/// In order to connect this view to the [MainView] a state management solution
/// like Provider or BloC is recommended.
class ContextDrawer extends StatelessWidget {
  const ContextDrawer({
    this.child,
    Key? key,
  }) : super(key: key);

  /// The content of this [ContextDrawer].
  final Widget? child;

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
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.only(right: 5.0),
      padding: const EdgeInsets.all(SizeConfig.basePadding),

      /// Should be the same as used in the other [StackedUI] widgets.
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SizeConfig.baseBorderRadius),
        ),
        color: ElevationOverlay.applyOverlay(
          context,
          Theme.of(context).colorScheme.surface,
          SizeConfig.baseBackgroundElevation,
        ),
      ),
      child: child,
    );
  }
}
