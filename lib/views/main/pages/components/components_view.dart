import 'package:campus_motorsport/provider/components/components_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/views/main/pages/components/add_component.dart';
import 'package:campus_motorsport/views/main/pages/components/all_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentsView extends StatelessWidget {
  const ComponentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();

    switch (viewProvider.currentPage) {
      case ComponentsPage.allComponents:
        return AllComponents();
      case ComponentsPage.addComponent:
        return AddComponent();
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
        children: children,
      ),
    );
  }
}
