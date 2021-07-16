import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/provider/user_management/user_management_provider.dart';
import 'package:campus_motorsport/provider/user_management/users_provider.dart';
import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/views/main/pages/home/home.dart';
import 'package:campus_motorsport/views/main/pages/user_management/user_management.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/primary_navigation_item.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/stacked_ui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
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
  late final List<Widget> _pages;

  /// The context menus of the main navigation.
  /// Length must be equal to [_pages].
  late final List<Widget?> _contextMenus;

  @override
  void initState() {
    super.initState();

    /// Read user to determine if admin pages need to be shown.
    final User? user = context.read<CurrentUser>().user;
    assert(user != null, 'Logged in users should never be null.');
    _pages = [
      Home(),
      if (user!.isAdmin) UserManagement(),
    ];
    _contextMenus = [
      HomeContext(),
      if (user.isAdmin) null, // user management
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => UserManagementProvider()),
        ChangeNotifierProvider(create: (context) => UsersProvider()),
      ],
      builder: (context, child) {
        return StackedUI(
          navigationDrawer: _buildDrawer(context),
          mainView: _pages[_currentIndex],
          contextDrawer: _contextMenus[_currentIndex],
          allowSlideToContext: _allowContextSlide(context),
        );
      },
    );
  }

  /// Determines if a context drawer should be visible.
  bool _allowContextSlide(BuildContext context) {
    if (_currentIndex == 0) {
      return context.watch<HomeProvider>().allowContextDrawer;
    } else if (_currentIndex == 1) {
      // User management
      return false;
    }
    return false;
  }

  /// Contains the main navigation items as well as the matching secondary items
  /// which are shown next to the main navigation bar.
  NavigationDrawer _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      selected: _currentIndex,
      navigationItems: <NavigationItemData>[
        /// HOME PAGE
        NavigationItemData(
          icon: LineIcons.home,
          onPressed: () {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
              });
            }
          },
          secondaryItem: HomeSecondary(),
        ),

        /// User management page. Only show to admins.
        if (context.read<CurrentUser>().user?.isAdmin ?? false)
          NavigationItemData(
            icon: LineIcons.users,
            onPressed: () {
              if (_currentIndex != 1) {
                setState(() {
                  _currentIndex = 1;
                });
              }
            },
            secondaryItem: UserManagementSecondary(),
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
    context.read<CurrentUser>().user = null;
    await auth.signOut();
  }
}
