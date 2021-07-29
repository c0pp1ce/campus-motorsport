import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/add_container.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentContainersView extends StatelessWidget {
  const ComponentContainersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CCViewProvider ccViewProvider = context.watch<CCViewProvider>();
    switch (ccViewProvider.currentPage) {
      case ComponentContainerPage.currentState:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
      case ComponentContainerPage.updates:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
      case ComponentContainerPage.addUpdate:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
      case ComponentContainerPage.addEvent:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
      case ComponentContainerPage.addComponent:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
      case ComponentContainerPage.addContainer:
        return AddContainer();
      case ComponentContainerPage.noContainers:
        return ExpandedAppBar(
          appbarTitle: Text('TODO'),
          appbarChild: Container(),
        );
    }
  }
}

class ComponentContainersContext extends StatelessWidget {
  const ComponentContainersContext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CCViewProvider ccViewProvider = context.watch<CCViewProvider>();
    switch (ccViewProvider.currentPage) {
      case ComponentContainerPage.currentState:
        return ContextDrawer(); // TODO : Filter list
      case ComponentContainerPage.updates:
        return ContextDrawer(); // TODO : Filter list
      case ComponentContainerPage.addUpdate:
        break;
      case ComponentContainerPage.addEvent:
        break;
      case ComponentContainerPage.addComponent:
        break;
      case ComponentContainerPage.addContainer:
        break;
      case ComponentContainerPage.noContainers:
        break;
    }
    return const SizedBox();
  }
}

class ComponentContainersSecondary extends StatelessWidget {
  const ComponentContainersSecondary({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CCViewProvider ccViewProvider = context.watch<CCViewProvider>();
    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;

    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            /// Add containers.
            if (isAdmin) ...[
              ListTile(
                title: Text(
                  ComponentContainerPage.addContainer.pageName,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: ccViewProvider.currentPage ==
                                ComponentContainerPage.addContainer
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                onTap: () {
                  ccViewProvider.switchTo(ComponentContainerPage.addContainer);
                },
              ),
              _buildDivider(context),
            ],

            /// Stocks
            ..._buildList(true, true, context, ccViewProvider),

            /// Vehicles
            ..._buildList(false, false, context, ccViewProvider),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(
    bool stocks,
    bool divider,
    BuildContext context,
    CCViewProvider ccViewProvider,
  ) {
    if ((ccViewProvider.stocks.isEmpty && stocks) ||
        (ccViewProvider.vehicles.isEmpty && !stocks)) {
      return [const SizedBox()];
    }

    final List<ComponentContainer> containers =
        stocks ? ccViewProvider.stocks : ccViewProvider.vehicles;

    return [
      ...containers.map((container) {
        /// Determine if a container page is currently opened.
        final bool containerOpened = ccViewProvider.currentPage !=
                ComponentContainerPage.addContainer &&
            ccViewProvider.currentPage != ComponentContainerPage.noContainers;

        /// Determine if the opened container is this container.
        final bool selected =
            containerOpened && ccViewProvider.currentlyOpen == container;

        /// Unselected containers only as simple list entries.
        if (!selected) {
          return ListTile(
            title: Text(
              container.name,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorServices.darken(
                      Theme.of(context).colorScheme.onSurface,
                      40,
                    ),
                  ),
            ),
            onTap: () {
              ccViewProvider.switchTo(
                ComponentContainerPage.currentState,
                openContainer: container,
              );
            },
          );
        } else {
          /// ExpansionTile in order to be able to display the sub menu.
          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              container.name,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            children: CCViewProvider.containerSpecificPages.map((page) {
              return ListTile(
                contentPadding: EdgeInsets.only(
                  left: SizeConfig.basePadding * 4,
                ),
                title: Text(
                  page.pageName,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ccViewProvider.currentPage == page
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                onTap: () {
                  ccViewProvider.switchTo(page);
                },
              );
            }).toList(),
          );
        }
      }),
      if (divider) _buildDivider(context),
    ];
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      indent: SizeConfig.basePadding,
      endIndent: SizeConfig.basePadding,
      height: SizeConfig.basePadding,
      thickness: 2,
      color: Theme.of(context).colorScheme.surface,
    );
  }
}