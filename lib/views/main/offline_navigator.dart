import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/provider/information/offline_information_provider.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/views/main/pages/information/information.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/primary_navigation_item.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/stacked_ui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class OfflineNavigator extends StatefulWidget {
  const OfflineNavigator({Key? key}) : super(key: key);

  @override
  _OfflineNavigatorState createState() => _OfflineNavigatorState();
}

class _OfflineNavigatorState extends State<OfflineNavigator> {
  int _currentIndex = 0;
  final GlobalKey<StackedUIState> uiKey = GlobalKey();

  /// The pages of the main navigation.
  /// Length must be equal to [_contextMenus].
  late final List<Widget> _pages;

  /// The context menus of the main navigation.
  /// Length must be equal to [_pages].
  late final List<Widget?> _contextMenus;

  void toggle() {
    uiKey.currentState?.toggle();
  }

  @override
  void initState() {
    super.initState();

    _pages = [
      const InformationView(
        offlineMode: true,
      ),
    ];
    _contextMenus = [
      null, // Information view
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => InformationViewProvider(
            toggle: toggle,
            offlineMode: true,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OfflineInformationProvider(
            offlineMode: true,
          ),
        ),
      ],
      builder: (context, child) {
        return StackedUI(
          key: uiKey,
          navigationDrawer: _buildDrawer(context),
          mainView: _pages[_currentIndex],
          contextDrawer: _contextMenus[_currentIndex],
          allowSlideToContext: _allowContextSlide(context),
        );
      },
    );
  }

  /// Contains the main navigation items as well as the matching secondary items
  /// which are shown next to the main navigation bar.
  Widget _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      selected: _currentIndex,
      navigationItems: <NavigationItemData>[
        /// Info
        NavigationItemData(
          icon: LineIcons.infoCircle,
          onPressed: () {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
                //toggle();
              });
            }
          },
          secondaryItem: const InformationViewSecondary(),
        ),

        /// LOGOUT
        /// Does not lead to any main page but rather returns the user to the login
        /// route.
        NavigationItemData(
          icon: Icons.logout,
          onPressed: () async {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
          secondaryItem: const Center(
            key: ValueKey('logout'),
            child: SizedBox(),
          ),
        ),
      ],
    );
  }

  /// Determines if a context drawer should be visible.
  bool _allowContextSlide(BuildContext context) {
    return false;
  }
}
