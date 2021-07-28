import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == text.
class ComponentText extends StatelessWidget {
  const ComponentText({
    required this.dataInput,
    this.minLines = 1,
    this.maxLines = 3,
    this.enabled = true,
    this.textInputType = TextInputType.multiline,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
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
        CMTextField(
          initialValue: dataInput.data,
          onSaved: (value) {
            dataInput.data = value;
          },
          minLines: minLines,
          maxLines: maxLines,
          enabled: enabled,
          textInputType: textInputType,
        ),
      ],
    );
  }
}
