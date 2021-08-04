import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/current_state.dart';
import 'package:campus_motorsport/widgets/component_containers/update_details.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateTile extends StatelessWidget {
  const UpdateTile({
    required this.update,
    Key? key,
  }) : super(key: key);

  final Update update;

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
              update.component.name,
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
      case ComponentStates.bad:
        return CurrentState.badState;
      case ComponentStates.ok:
        return CurrentState.okState;
      case ComponentStates.newComponent:
        return CurrentState.newState;
    }
  }
}
