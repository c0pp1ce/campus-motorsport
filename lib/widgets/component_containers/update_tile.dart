import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/current_state.dart';
import 'package:campus_motorsport/widgets/component_containers/update_details.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateTile extends StatelessWidget {
  const UpdateTile({
    required this.update,
    required this.removed,
    Key? key,
  }) : super(key: key);

  final Update update;

  /// Indicator if this component has been removed from the app.
  final bool removed;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(
        vertical: SizeConfig.basePadding,
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => UpdateDetails(update: update)),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        tileColor: stateColor.withOpacity(CurrentState.tileStateColorOpacity),
        contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              !removed
                  ? update.component.name
                  : '${update.component.name} - GELÖSCHT',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              update.component.category.name,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(
              height: SizeConfig.basePadding,
            ),
            Text(
              DateFormat.yMMMMd().format(update.date),
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: ColorServices.darken(
                      Theme.of(context).colorScheme.onSurface,
                      SizeConfig.darkenTextColorBy ~/ 2,
                    ),
                    fontSize: 14,
                  ),
            ),
            const SizedBox(
              height: SizeConfig.basePadding,
            ),
            Text(
              update.by,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: ColorServices.darken(
                      Theme.of(context).colorScheme.onSurface,
                      SizeConfig.darkenTextColorBy ~/ 2,
                    ),
                    fontSize: 14,
                  ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.circle,
          color: stateColor,
          size: 28,
        ),
      ),
    );
  }

  Color get stateColor {
    switch (update.component.state) {
      case ComponentState.bad:
        return CurrentState.badState;
      case ComponentState.ok:
        return CurrentState.okState;
      case ComponentState.newComponent:
        return CurrentState.newState;
    }
  }
}
