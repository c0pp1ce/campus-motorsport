import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          ..._buildList(true, context, ccViewProvider),

          /// Vehicles
          ..._buildList(false, context, ccViewProvider),
        ],
      ),
    );
  }

  List<Widget> _buildList(
    bool stocks,
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
      ...containers.map((stock) {
        return Container(
          height: 10,
          color: Colors.red,
        );
      }),
      _buildDivider(context),
    ];
  }

  Widget _buildDivider(BuildContext context) {
    return const Divider(
      indent: SizeConfig.basePadding,
      endIndent: SizeConfig.basePadding,
      height: SizeConfig.basePadding,
      thickness: 2,
    );
  }
}
