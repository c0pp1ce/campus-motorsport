import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/views/main/pages/home.dart';
import 'package:campus_motorsport/views/main/pages/vehicles.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/stacked_ui.dart';
import 'package:flutter/material.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  /// The pages of the main navigation.
  late List<Widget> pages = [
    Home("Home"),
    Vehicles("Fahrzeuge"),
  ];

  /// The context menus of the main navigation.
  late List<Widget> contextMenus = [
    HomeContext(),
    VehiclesContext(),
  ];

  @override
  Widget build(BuildContext context) {
    return StackedUI(
      navigationDrawer: _buildDrawer(context),
      mainView: pages[_currentIndex],
      contextDrawer: contextMenus[_currentIndex],
    );
  }

  NavigationDrawer _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      selected: _currentIndex,
      navigationItems: <NavigationItemData>[
        /// HOME
        NavigationItemData(
          icon: Icons.home,
          onPressed: () {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
              });
            }
          },
          secondaryItem: Center(
            key: UniqueKey(),
            child: Text(
              "Home Secondary",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),

        /// TEST
        NavigationItemData(
          icon: Icons.car_repair,
          onPressed: () {
            if (_currentIndex != 1) {
              setState(() {
                _currentIndex = 1;
              });
            }
          },
          secondaryItem: Center(
            key: UniqueKey(),
            child: Text(
              "Vehicles Secondary",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),

        /// Logout
        NavigationItemData(
          icon: Icons.logout,
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
          secondaryItem: Center(
            key: UniqueKey(),
            child: Container(),
          ),
        ),
      ],
    );
  }
}
