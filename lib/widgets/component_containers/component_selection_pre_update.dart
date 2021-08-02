import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/component_selection_tile.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:flutter/material.dart';

/// Simple list view where a user can select which components he wants to
/// update.
class ComponentSelectionPreUpdate extends StatelessWidget {
  const ComponentSelectionPreUpdate({
    required this.components,
    required this.doneButton,
    required this.onSelect,
    required this.selectedValues,
    Key? key,
  }) : super(key: key);

  final Widget doneButton;
  final List<BaseComponent> components;
  final List<bool> selectedValues;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          itemCount: components.length,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            late final bool categoryChanged;
            if (index == 0) {
              categoryChanged = true;
            } else {
              if (components[index - 1].category !=
                  components[index].category) {
                categoryChanged = true;
              } else {
                categoryChanged = false;
              }
            }

            final Widget child = ComponentSelectionTile(
              component: components[index],
              selected: selectedValues[index],
              onSelect: () {
                onSelect(index);
              },
            );

            if (categoryChanged) {
              return Column(
                children: <Widget>[
                  if (index != 0)
                    const SizedBox(
                      height: SizeConfig.basePadding,
                    ),
                  ListSubHeader(
                    header: components[index].category.name,
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
        Padding(
          padding: const EdgeInsets.all(
            SizeConfig.basePadding,
          ).add(
            EdgeInsets.only(bottom: SizeConfig.basePadding),
          ),
          child: doneButton,
        ),
      ],
    );
  }
}
