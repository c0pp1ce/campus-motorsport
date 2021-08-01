import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget which displays a list of unused(aka never updated) components
/// if there are any for the currently opened container.
class UnusedComponents extends StatefulWidget {
  const UnusedComponents({Key? key}) : super(key: key);

  @override
  _UnusedComponentsState createState() => _UnusedComponentsState();
}

class _UnusedComponentsState extends State<UnusedComponents> {
  late ComponentCategories previousCategory;

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();
    if (viewProvider.currentlyOpen == null) {
      return Center(
        child: Text('Fehler beim Laden.'),
      );
    }

    if (viewProvider.currentlyOpen!.components.length ==
        viewProvider.currentlyOpen!.currentState.length) {
      return const SizedBox();
    }

    final List<String> unusedComponents = [];
    viewProvider.currentlyOpen!.components.forEach(unusedComponents.add);
    for (final update in viewProvider.currentlyOpen!.currentState) {
      unusedComponents.remove(update.component.id);
    }

    final List<BaseComponent> components =
        context.watch<ComponentsProvider>().components;

    return Column(
      children: <Widget>[
        Text(
          'Nicht gewartete Komponenten',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: unusedComponents.length,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final BaseComponent component = components
                .firstWhere((element) => element.id == unusedComponents[index]);

            late final bool categoryChanged;
            if (index == 0) {
              categoryChanged = true;
              previousCategory = component.category;
            } else {
              if (component.category != previousCategory) {
                categoryChanged = true;
                previousCategory = component.category;
              } else {
                categoryChanged = false;
              }
            }

            final Widget child = SimpleCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(
                vertical: SizeConfig.basePadding,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(component.name),
                    Text(
                      component.category.name,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                  ],
                ),
              ),
            );

            if (categoryChanged) {
              return Column(
                children: <Widget>[
                  if (index != 0)
                    const SizedBox(
                      height: SizeConfig.basePadding,
                    ),
                  ListSubHeader(
                    header: component.category.name,
                  ),
                  const SizedBox(
                    height: SizeConfig.basePadding,
                  ),
                  child,
                ],
              );
            } else {
              return child;
            }
          },
        ),
      ],
    );
  }
}
