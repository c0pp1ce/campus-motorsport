import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Simple card to display the components name and category as well as providing
/// selection-functionality.
///
/// Used for adding components to a components container.
class ComponentSelectionTile extends StatelessWidget {
  const ComponentSelectionTile({
    required this.component,
    required this.selected,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  final BaseComponent component;
  final bool selected;
  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(SizeConfig.basePadding),
      child: ListTile(
        contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
        tileColor: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : null,
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
        trailing: Container(
          width: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primaryVariant.withOpacity(1)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          child: selected
              ? Icon(
                  LineIcons.check,
                  color: Theme.of(context).colorScheme.primaryVariant,
                  size: 20,
                )
              : null,
        ),
        onTap: onSelect,
      ),
    );
  }
}
