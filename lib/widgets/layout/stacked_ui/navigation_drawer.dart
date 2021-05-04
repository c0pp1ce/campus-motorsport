import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/primary_nav_item.dart';
import 'package:flutter/material.dart';

/// The left view of the stacked UI which us used for navigation.
///
/// 2 Layers of navigation possible.
class NavigationDrawer extends StatelessWidget {
  /// The widgets which are displayed in the horizontal list on the left side.
  final List<NavigationItemData> navigationItems;

  final int selected;

  NavigationDrawer({
    required this.navigationItems,
    required this.selected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 0,
          child: _buildMainMenu(context),
        ),
        Expanded(
          child: _buildSecondary(context),
        ),
        const SizedBox(
          width: 55,
        ),
      ],
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    return Container(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: SizeConfig.screenHeight,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: navigationItems.length,
        itemBuilder: (context, index) {
          return PrimaryNavigationItem(
            isSelected: index == selected,
            icon: navigationItems[index].icon,
            onPressed: navigationItems[index].onPressed,
          );
        },
      ),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: const Radius.circular(15.0),
          ),
          color: ElevationOverlay.applyOverlay(
              context, Theme.of(context).colorScheme.surface, 5),
        ),
        padding: const EdgeInsets.all(10.0),
        child: AnimatedSwitcher(
          child: navigationItems[selected].secondaryItem,
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              child: child,
              scale: animation,
            );
          },
        ),
      ),
    );
  }
}

class NavigationItemData {
  final IconData icon;
  final void Function() onPressed;
  final Widget secondaryItem;

  NavigationItemData({
    required this.icon,
    required this.onPressed,
    required this.secondaryItem,
  });
}
