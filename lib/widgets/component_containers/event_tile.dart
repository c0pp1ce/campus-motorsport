import 'package:campus_motorsport/models/component_containers/event.dart' as cm;
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    required this.event,
    Key? key,
  }) : super(key: key);

  final cm.Event event;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(
        vertical: SizeConfig.basePadding,
      ),
      child: ListTile(
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),*/
        contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              event.decrementCounterBy == 0 || event.decrementCounterBy > 1
                  ? '${event.decrementCounterBy} Fahrten'
                  : '${event.decrementCounterBy} Fahrt',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (event.description?.isNotEmpty ?? false) ...[
              const SizedBox(
                height: SizeConfig.basePadding,
              ),
              Text(
                event.description!,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: ColorServices.darken(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                      fontSize: 14,
                    ),
              ),
            ],
            const SizedBox(
              height: SizeConfig.basePadding,
            ),
            Text(
              DateFormat.yMMMMd().format(event.date),
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: ColorServices.darken(
                      Theme.of(context).colorScheme.onSurface,
                      SizeConfig.darkenTextColorBy ~/ 2,
                    ),
                    fontSize: 14,
                  ),
            ),
            Text(
              event.by,
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
      ),
    );
  }
}
