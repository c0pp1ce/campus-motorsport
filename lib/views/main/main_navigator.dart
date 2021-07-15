import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/views/main/pages/home/home.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/primary_navigation_item.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/stacked_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The navigator for the main pages which use the stacked UI.
///
/// Provider or BloCs needed for those pages need to be inserted above the [StackedUI]
/// widget.
class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  /// The pages of the main navigation.
  /// Length must be equal to [_contextMenus].
  final List<Widget> _pages = [
    Home(),
  ];

  /// The context menus of the main navigation.
  /// Length must be equal to [_pages].
  final List<Widget> _contextMenus = [
    HomeContext(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(),
        ),
      ],
      builder: (context, child) {
        return StackedUI(
          navigationDrawer: _buildDrawer(context),
          mainView: _pages[_currentIndex],
          contextDrawer: _contextMenus[_currentIndex],
        );
      },
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
          secondaryItem: HomeSecondary(),
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
            key: ValueKey('logout'),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  /// Reset user specific providers on logout.
  Future<void> _logout(BuildContext context) async {
    final CMAuth auth = CMAuth();
    await auth.signOut();
  }
}
