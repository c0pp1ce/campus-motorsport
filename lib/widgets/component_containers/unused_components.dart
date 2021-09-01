import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget which displays a list of updates.
class UnusedComponents extends StatefulWidget {
  const UnusedComponents({
    this.isAdmin = false,
    Key? key,
  }) : super(key: key);

  final bool isAdmin;

  @override
  _UnusedComponentsState createState() => _UnusedComponentsState();
}

class _UnusedComponentsState extends State<UnusedComponents> {
  late ComponentCategory previousCategory;
  late List<String> unusedComponentIds;
  late List<BaseComponent> unusedComponents;

  @override
  void didChangeDependencies() {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();
    unusedComponentIds = [];

    /// Determine which components have not been updated at all.
    viewProvider.currentlyOpen!.components.forEach(unusedComponentIds.add);
    for (final update in viewProvider.currentlyOpen!.currentState) {
      unusedComponentIds.remove(update.component.id);
    }

    /// Map never updated component ids to their components.
    final List<BaseComponent> components =
        context.watch<ComponentsProvider>().components;
    unusedComponents = components
        .where((element) => unusedComponentIds.contains(element.id))
        .toList();
    unusedComponents.sort(BaseComponent.compareComponents);
    super.didChangeDependencies();
  }

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
            late final bool categoryChanged;
            if (index == 0) {
              categoryChanged = true;
              previousCategory = unusedComponents[index].category;
            } else {
              if (unusedComponents[index].category != previousCategory) {
                categoryChanged = true;
                previousCategory = unusedComponents[index].category;
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(unusedComponents[index].name),
                    Text(
                      unusedComponents[index].category.name,
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
                    header: unusedComponents[index].category.name,
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
