import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';

/// Simple view to see the details of an update.
class UpdateDetails extends StatelessWidget {
  const UpdateDetails({
    required this.update,
    Key? key,
  }) : super(key: key);

  final Update update;

  @override
  Widget build(BuildContext context) {
    return MainView(
      backgroundElevation: ExpandedAppBar.elevation,
      implyLeading: true,
      title: Text('Details'),
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: SizeConfig.basePadding,
          ).add(
            EdgeInsets.only(top: SizeConfig.basePadding * 2),
          ),
          child: VehicleComponent(
            component: update.component,
            highlightInputs: true,
            currentEventCounter: update.eventCounter,
          ),
        ),
      ),
    );
  }
}
