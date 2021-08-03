import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_date_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Used to display DataInput with type == date.
class ComponentDate extends StatelessWidget {
  const ComponentDate({
    required this.dataInput,
    this.previousData,
    this.enabled = true,
    this.highlightInput = false,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final DataInput? previousData;
  final bool enabled;
  final bool highlightInput;

  @override
  Widget build(BuildContext context) {
    assert(dataInput.data is DateTime || dataInput.data == null,
        'Wrong data format.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CMLabel(
          label: dataInput.name,
          darken: highlightInput,
        ),
        if (dataInput.description.isNotEmpty) ...[
          Text(
            dataInput.description,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: highlightInput
                      ? ColorServices.darken(
                          Theme.of(context).colorScheme.onSurface,
                          VehicleComponent.darkenTextBy,
                        )
                      : null,
                ),
          ),
        ],
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        CMDatePicker(
          initialValue: dataInput.data,
          onSaved: (dateTime) {
            dataInput.data = dateTime;
          },
          enabled: enabled,
        ),
        if (_showPreviousValue) ...[
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          Text(
            'Vorheriger Wert',
            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
          ),
          Text(
            DateFormat.yMMMMd().format(previousData!.data),
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
          ),
        ],
      ],
    );
  }

  bool get _showPreviousValue {
    return previousData != null;
  }
}
