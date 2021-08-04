import 'package:campus_motorsport/models/component_containers/event.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/event_tile.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsList extends StatelessWidget {
  const EventsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    if(viewProvider.currentlyOpen?.events.isEmpty ?? true) {
      return Center(
        child: Text('Kein Events gefunden.'),
      );
    }

    return ListView.builder(
      itemCount: viewProvider.currentlyOpen!.events.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final child = EventTile(
          event: viewProvider.currentlyOpen!.events[index],
        );

        late final bool titleChanged;
        if (index == 0) {
          titleChanged = true;
        } else {
          if (differentDay(viewProvider.currentlyOpen!.events, index)) {
            titleChanged = true;
          } else {
            titleChanged = false;
          }
        }

        if (titleChanged) {
          return Column(
            children: <Widget>[
              if (index != 0)
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
              ListSubHeader(
                header: DateFormat.yMMMMd()
                    .format(viewProvider.currentlyOpen!.events[index].date),
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
    );
  }

  bool differentDay(List<Event> events, int index) {
    return events[index].date.year != events[index - 1].date.year ||
        events[index].date.month != events[index - 1].date.month ||
        events[index].date.day != events[index - 1].date.day;
  }
}
