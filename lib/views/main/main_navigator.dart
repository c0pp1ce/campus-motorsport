import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/component_containers/cc_provider.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/provider/components/components_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/provider/information/clipboard_provider.dart';
import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/provider/information/offline_information_provider.dart';
import 'package:campus_motorsport/provider/user_management/user_management_provider.dart';
import 'package:campus_motorsport/provider/user_management/users_provider.dart';
import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/component_containers.dart';
import 'package:campus_motorsport/views/main/pages/components/components_view.dart';
import 'package:campus_motorsport/views/main/pages/home/home.dart';
import 'package:campus_motorsport/views/main/pages/information/information.dart';
import 'package:campus_motorsport/views/main/pages/user_management/user_management.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/navigation_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/primary_navigation_item.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/stacked_ui.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// The navigator for the main pages which use the stacked UI.
///
/// Provider or BloCs needed for those pages need to be inserted above the [StackedUI]
/// widget.
class MainNavigator extends StatefulWidget {
  const MainNavigator({
    Key? key,
  }) : super(key: key);

  @override
  MainNavigatorState createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  final GlobalKey<StackedUIState> uiKey = GlobalKey();

  /// The pages of the main navigation.
  /// Length must be equal to [_contextMenus].
  late final List<Widget> _pages;

  /// The context menus of the main navigation.
  /// Length must be equal to [_pages].
  late final List<Widget?> _contextMenus;

  void toggle([bool onlyOpenMain = false]) {
    uiKey.currentState?.toggle(onlyOpenMain);
  }

  void setIndex(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();

    /// Read user to determine if admin pages need to be shown.
    final User? user = context.read<CurrentUser>().user;
    _pages = [
      Home(
        setIndex: setIndex,
      ),
      const ComponentContainersView(), // vehicles, stocks
      const ComponentsView(),
      const InformationView(),
      if (user?.isAdmin ?? false) const UserManagement(),
    ];
    _contextMenus = [
      null,
      const ComponentContainersContext(), // vehicles, stocks
      const ComponentsViewContext(), // components
      const InformationContext(), // Info
      if (user?.isAdmin ?? false) null, // user management
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (auth.FirebaseAuth.instance.currentUser?.uid == null) {
          return true;
        }
        await CrudUser().updateField(
          uid: auth.FirebaseAuth.instance.currentUser!.uid,
          key: 'onSite',
          data: false,
        );
        return true;
      },
      child: MultiProvider(
        providers: _providers,
        builder: (context, child) {
          return StackedUI(
            key: uiKey,
            navigationDrawer: _buildDrawer(context),
            mainView: _pages[_currentIndex],
            contextDrawer: _contextMenus[_currentIndex],
            allowSlideToContext: _allowContextSlide(context),
          );
        },
      ),
    );
  }

  List<SingleChildWidget> get _providers {
    return [
      ChangeNotifierProvider(
        create: (context) => HomeProvider(
          toggle: toggle,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ComponentsViewProvider(
          toggle: toggle,
        ),
      ),
      ChangeNotifierProvider(create: (context) => ComponentsProvider()),
      ChangeNotifierProvider(create: (context) => VehiclesProvider()),
      ChangeNotifierProvider(create: (context) => StocksProvider()),
      ChangeNotifierProxyProvider2<VehiclesProvider, StocksProvider,
          CCViewProvider>(
        create: (context) => CCViewProvider(
          toggle: toggle,
          vehicles: Provider.of<VehiclesProvider>(context, listen: false)
              .getContainersBuildSafe(),
          stocks: Provider.of<StocksProvider>(context, listen: false)
              .getContainersBuildSafe(),
          isAdmin:
              Provider.of<CurrentUser>(context, listen: false).user?.isAdmin ??
                  false,
        ),
        update: _updateCCViewProvider,
      ),
      ChangeNotifierProvider(
        create: (context) => InformationViewProvider(toggle: toggle),
      ),
      ChangeNotifierProvider(
        create: (context) => OfflineInformationProvider(
          offlineMode: false,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ClipboardProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserManagementProvider(
          toggle: toggle,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => UsersProvider(),
      ),
    ];
  }

  /// Determines if a context drawer should be visible.
  bool _allowContextSlide(BuildContext context) {
    if (_currentIndex == 1) {
      return context.watch<CCViewProvider>().allowContextDrawer;
    } else if (_currentIndex == 2) {
      return context.watch<ComponentsViewProvider>().allowContextDrawer;
    } else if (_currentIndex == 3) {
      return context.watch<InformationViewProvider>().allowContextDrawer;
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
                //toggle();
              });
            }
          },
          secondaryItem: const HomeSecondary(),
        ),

        /// Vehicles
        NavigationItemData(
          active: context.watch<CCViewProvider>().currentPage !=
              ComponentContainerPage.noContainers,
          icon: LineIcons.car,
          onPressed: () {
            if (_currentIndex != 1) {
              setState(() {
                _currentIndex = 1;
                //toggle();
              });
            }
          },
          secondaryItem: const ComponentContainersSecondary(),
        ),

        /// Components
        NavigationItemData(
          icon: LineIcons.boxes,
          onPressed: () {
            if (_currentIndex != 2) {
              setState(() {
                _currentIndex = 2;
                //toggle();
              });
            }
          },
          secondaryItem: const ComponentsViewSecondary(),
        ),

        /// Info
        NavigationItemData(
          icon: LineIcons.infoCircle,
          onPressed: () {
            if (_currentIndex != 3) {
              setState(() {
                _currentIndex = 3;
                //toggle();
              });
            }
          },
          secondaryItem: const InformationViewSecondary(),
        ),

        /// User management page. Only show to admins.
        if (context.read<CurrentUser>().user?.isAdmin ?? false)
          NavigationItemData(
            icon: LineIcons.users,
            onPressed: () {
              if (_currentIndex != 4) {
                setState(() {
                  _currentIndex = 4;
                  //toggle();
                });
              }
            },
            secondaryItem: const UserManagementSecondary(),
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
          secondaryItem: const Center(
            key: ValueKey('logout'),
            child: SizedBox(),
          ),
        ),
      ],
    );
  }

  /// Update function for the proxy provider which is needed to react to changes
  /// inside of the vehicle or stocks providers.
  CCViewProvider _updateCCViewProvider(
    BuildContext context,
    VehiclesProvider vehicleProvider,
    StocksProvider stocksProvider,
    CCViewProvider? viewProvider,
  ) {
    final bool isAdmin =
        Provider.of<CurrentUser>(context, listen: false).user?.isAdmin ?? false;

    /// No CCViewProvider or on placeholder page.
    if (viewProvider == null ||
        viewProvider.currentPage == ComponentContainerPage.noContainers ||
        (viewProvider.vehicles.isEmpty &&
            viewProvider.stocks.isEmpty &&
            viewProvider.currentPage == ComponentContainerPage.addContainer &&
            viewProvider.isAdmin)) {
      return CCViewProvider(
        toggle: toggle,
        vehicles: vehicleProvider.containers,
        stocks: stocksProvider.containers,
        isAdmin: isAdmin,
      );
    }

    /// User somehow lost his admin rights.
    if (viewProvider.isAdmin == true && isAdmin == false) {
      setState(() {
        _currentIndex = 0;
        _showRedirectInfo('Admin-Rechte', context);
      });
      return CCViewProvider(
        toggle: toggle,
        vehicles: vehicleProvider.containers,
        stocks: stocksProvider.containers,
        isAdmin: isAdmin,
      );
    }

    /// Check if currently open container was removed.
    if (viewProvider.currentlyOpen != null &&
        _currentIndex == 1 &&
        CCViewProvider.containerSpecificPages
            .contains(viewProvider.currentPage)) {
      switch (viewProvider.currentlyOpen!.type) {
        case ComponentContainerType.stock:
          late final bool objectNotFound;
          final ComponentContainer o = stocksProvider.containers.firstWhere(
              (element) => element.id == viewProvider.currentlyOpen!.id,
              orElse: () {
            return ComponentContainer(
              id: '',
              name: '',
              type: ComponentContainerType.vehicle,
            );
          });
          if (o.id.isEmpty) {
            objectNotFound = true;
          } else {
            objectNotFound = false;
          }
          if (objectNotFound || viewProvider.currentlyOpen!.id == null) {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              setState(() {
                _currentIndex = 0;
                _showRedirectInfo('Lager', context);
              });
            });
            return CCViewProvider(
              toggle: toggle,
              vehicles: vehicleProvider.containers,
              stocks: stocksProvider.containers,
              isAdmin: isAdmin,
            );
          } else {
            break;
          }
        case ComponentContainerType.vehicle:
          late final bool objectNotFound;
          final ComponentContainer o = vehicleProvider.containers.firstWhere(
              (element) => element.id == viewProvider.currentlyOpen!.id,
              orElse: () {
            return ComponentContainer(
              id: '',
              name: '',
              type: ComponentContainerType.vehicle,
            );
          });
          if (o.id.isEmpty) {
            objectNotFound = true;
          } else {
            objectNotFound = false;
          }
          if (objectNotFound || viewProvider.currentlyOpen!.id == null) {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              setState(() {
                _currentIndex = 0;
                _showRedirectInfo('Fahrzeug', context);
              });
            });
            return CCViewProvider(
              toggle: toggle,
              vehicles: vehicleProvider.containers,
              stocks: stocksProvider.containers,
              isAdmin: isAdmin,
            );
          } else {
            break;
          }
      }
    }

    /// Return provider with updated lists.
    viewProvider.vehicles = vehicleProvider.containers;
    viewProvider.stocks = stocksProvider.containers;
    viewProvider.notify();
    return viewProvider;
  }

  /// Shown if a vehicle or stock is deleted while a user is viewing it (if the
  /// data is reloaded by the user at some point).
  void _showRedirectInfo(String type, BuildContext context) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.info,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: '$type nicht gefunden.',
      text:
          'Umleitung zum Homescreen da die betrachteten Daten nicht mehr gefunden wurden.\n'
          'Eventuell wurden sie gelöscht.',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'VERSTANDEN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }

  /// Reset user specific providers on logout.
  Future<void> _logout(BuildContext context) async {
    final CMAuth auth = CMAuth();
    await context.read<CurrentUser>().setOnSiteState(false);
    context.read<CurrentUser>().user = null;
    await auth.signOut();
  }
}
