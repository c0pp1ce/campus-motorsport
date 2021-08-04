import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEvent extends StatelessWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    if (viewProvider.currentlyOpen == null) {
      return const ExpandedAppBar(
        appbarTitle: Text('Fehler beim Laden.'),
        offsetBeforeTitleShown: 60,
        appbarChild: Center(
          child: Text('Fehler beim Laden.'),
        ),
      );
    }

    return ExpandedAppBar(
      appbarTitle: Text(
        'Event eintragen',
        style: Theme.of(context).textTheme.headline6,
      ),
      offsetBeforeTitleShown: 50,
      appbarChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ExpandedTitle(title: 'Event eintragen'),
          Text(
            viewProvider.currentlyOpen!.name,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
