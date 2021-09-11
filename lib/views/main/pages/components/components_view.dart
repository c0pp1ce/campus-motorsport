import 'package:campus_motorsport/provider/components/components_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/components/add_component.dart';
import 'package:campus_motorsport/views/main/pages/components/all_components.dart';
import 'package:campus_motorsport/widgets/general/buttons/category_filter_chips.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ComponentsView extends StatelessWidget {
  const ComponentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();

    switch (viewProvider.currentPage) {
      case ComponentsPage.allComponents:
        return const AllComponents();
      case ComponentsPage.addComponent:
        return const AddComponent();
    }
  }
}

class ComponentsViewSecondary extends StatelessWidget {
  const ComponentsViewSecondary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();
    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;
    final List<Widget> children = [
      ListTile(
        onTap: () {
          viewProvider.switchTo(ComponentsPage.allComponents);
        },
        title: Text(
          ComponentsPage.allComponents.pageName,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: viewProvider.currentPage == ComponentsPage.allComponents
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
        ),
      ),
    ];

    /// Only admins can add new components.
    if (isAdmin) {
      children.add(
        ListTile(
          onTap: () {
            viewProvider.switchTo(ComponentsPage.addComponent);
          },
          title: Text(
            ComponentsPage.addComponent.pageName,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: viewProvider.currentPage == ComponentsPage.addComponent
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}

/// Only used in All components.
class ComponentsViewContext extends StatelessWidget {
  const ComponentsViewContext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();

    if (viewProvider.currentPage == ComponentsPage.allComponents) {
      return ContextDrawer(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(SizeConfig.basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CategoryFilterChips(filterProvider: viewProvider),
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
                _buildInfo(
                  context,
                  'Tippe auf eine Komponente um die Detailansicht zu öffnen.',
                  LineIcons.infoCircle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Every other components page.
    return const SizedBox();
  }

  Widget _buildInfo(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 65,
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
