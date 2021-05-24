import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/primary_navigation_item.dart';

import 'package:flutter/material.dart';

/// The left view of the stacked UI which is used for navigation.
///
/// 2 Layers of navigation possible.
class NavigationDrawer extends StatelessWidget {
  /// Used to build the widgets which are displayed in the horizontal list on the left side.
  final List<NavigationItemData> navigationItems;

  /// The currently selected page.
  final int selected;

  const NavigationDrawer({
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
          /// The width occupied by the inactive [MainView] plus the margin between
          /// it and the [NavigationDrawer] content.
          width: 55,
        ),
      ],
    );
  }

  /// Build a list of circular buttons ([PrimaryNavigationItem]) which form the main navigation.
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

  /// Places the [secondaryItem] of each [NavigationItemData] in a predefined [Container]
  /// with maximum available height and width.
  Widget _buildSecondary(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,

        /// Should be the same as used in the other [StackedUI] widgets.
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