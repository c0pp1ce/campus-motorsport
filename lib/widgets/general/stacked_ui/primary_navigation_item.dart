import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';

import 'package:flutter/material.dart';

/// A circle button with an avatar and selected indicator.
class PrimaryNavigationItem extends StatelessWidget {
  const PrimaryNavigationItem({
    required this.isSelected,
    required this.icon,
    required this.onPressed,
    this.active = true,
    Key? key,
  }) : super(key: key);

  final bool isSelected;
  final IconData icon;
  final void Function() onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CMTextButton(
        width: 50,
        height: 50,
        onPressed: active ? onPressed : null,
        child: Icon(icon),
        noGradient: true,
        radius: BorderRadius.circular(50.0),
        backgroundColor: ElevationOverlay.applyOverlay(
            context,
            Theme.of(context).colorScheme.surface,
            SizeConfig.baseBackgroundElevation),
        primary: active
            ? isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

/// A wrapper class for the data that each navigation item used by the [NavigationDrawer]
/// needs.
class NavigationItemData {
  const NavigationItemData({
    required this.icon,
    required this.onPressed,
    required this.secondaryItem,
    this.active = true,
  });

  /// The [IconData] displayed on the circular navigation item.
  final IconData icon;

  /// The function which will be executed when pressing the circular navigation item.
  final void Function() onPressed;

  /// Will be placed inside the second layer of navigation..
  final Widget secondaryItem;

  final bool active;
}
