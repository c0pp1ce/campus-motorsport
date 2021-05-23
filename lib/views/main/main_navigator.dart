import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/controller/token_controller/token_event.dart';
import 'package:campus_motorsport/infrastructure/auth/cm_auth.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/views/main/pages/home.dart';
import 'package:campus_motorsport/views/main/pages/vehicles.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/stacked_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The navigator for the main pages which use the stacked UI.
///
/// Provider or BloCs needed for those pages need to be inserted above the [StackedUI]
/// widget.
class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  /// The pages of the main navigation.
  /// Length must be equal to [_contextMenus].
  late List<Widget> _pages = [
    Home(),
    Vehicles("Fahrzeuge"),
  ];

  /// The context menus of the main navigation.
  /// Length must be equal to [_pages].
  late List<Widget> _contextMenus = [
    HomeContext(),
    VehiclesContext(),
  ];

  @override
  Widget build(BuildContext context) {
    return StackedUI(
      navigationDrawer: _buildDrawer(context),
      mainView: _pages[_currentIndex],
      contextDrawer: _contextMenus[_currentIndex],
    );
  }

  /// Contains the main navigation items as well as the matching secondary items
  /// which are shown next to the main navigation bar.
  NavigationDrawer _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      selected: _currentIndex,
      navigationItems: <NavigationItemData>[
        /// HOME PAGE
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
            key: ValueKey("home"),
            child: Text(
              "Home Secondary",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),

        /// TEST TODO : Remove
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
            key: ValueKey("vehicles"),
            child: Text(
              "Vehicles Secondary",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),

        /// LOGOUT
        /// Does not lead to any main page but rather returns the user to the login
        /// route.
        /// The onPressed needs to handle everything logout-related.
        NavigationItemData(
          icon: Icons.logout,
          onPressed: () async {
            await _logout(context);
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
          secondaryItem: Center(
            key: ValueKey("logout"),
            child: Container(),
          ),
        ),
      ],
    );
  }

  /// Reset user specific providers on logout.
  Future<void> _logout(BuildContext context) async {
    Provider.of<TokenController>(context, listen: false).add(DeleteToken());
    CMAuth auth = CMAuth();
    await auth.signOut();
  }
}
