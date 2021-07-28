import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_date_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == date.
class ComponentDate extends StatelessWidget {
  const ComponentDate({
    required this.dataInput,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    assert(dataInput.data is DateTime || dataInput.data == null,
        'Wrong data format.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CMLabel(label: dataInput.name),
        if (dataInput.description.isNotEmpty) ...[
          Text(dataInput.description),
        ],
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        CMDatePicker(
          onSaved: (dateTime) {
            dataInput.data = dateTime;
          },
          enabled: enabled,
        )
      ],
    );
  }
}
