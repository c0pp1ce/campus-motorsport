import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/update_tile.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Displays the current state (as list of updates).
class StateUpdates extends StatelessWidget {
  const StateUpdates({
    required this.updates,
    this.titlesBasedOfDate = false,
    Key? key,
  }) : super(key: key);

  final List<Update> updates;
  final bool titlesBasedOfDate;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: updates.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final child = UpdateTile(update: updates[index]);

        late final bool titleChanged;
        if (index == 0) {
          titleChanged = true;
        } else {
          if ((!titlesBasedOfDate &&
                  updates[index].component.category !=
                      updates[index - 1].component.category) ||
              titlesBasedOfDate && differentDay(index)) {
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
                header: !titlesBasedOfDate
                    ? updates[index].component.category.name
                    : DateFormat.yMMMMd().format(updates[index].date),
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

  bool differentDay(int index) {
    return updates[index].date.year != updates[index - 1].date.year ||
        updates[index].date.month != updates[index - 1].date.month ||
        updates[index].date.day != updates[index - 1].date.day;
  }
}
