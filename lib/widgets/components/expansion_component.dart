import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Wrapper for a component which uses an [ExpansionTile] to keep list views
/// clean.
class ExpansionComponent extends StatelessWidget {
  const ExpansionComponent({
    required this.isAdmin,
    required this.component,
    required this.showDeleteDialog,
    Key? key,
  }) : super(key: key);

  final bool isAdmin;
  final BaseComponent component;
  final void Function(BaseComponent) showDeleteDialog;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      margin: const EdgeInsets.all(SizeConfig.basePadding),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(
          SizeConfig.basePadding,
        ),
        childrenPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  component.name,
                ),
                Text(
                  component.category.name,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            if (isAdmin)
              IconButton(
                onPressed: () {
                  showDeleteDialog(component);
                },
                icon: Icon(
                  LineIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        children: [
          VehicleComponent(
            showBaseData: false,
            component: component,
          )
        ],
      ),
    );
  }
}
