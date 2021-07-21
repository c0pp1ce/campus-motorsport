import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';

/// used to display DataInput with type == text.
class ComponentText extends StatelessWidget {
  const ComponentText({
    required this.name,
    required this.description,
    required this.onSaved,
    this.initialValue,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final String name;
  final String description;
  final String? initialValue;
  final void Function(String?) onSaved;
  final bool enabled;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CMLabel(label: name),
        if(description.isNotEmpty) ...[
          Text(description),
        ],
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        CMTextField(
          onSaved: onSaved,
          minLines: minLines,
          maxLines: maxLines,
          enabled: enabled,
          textInputType: TextInputType.text,
        ),
      ],
    );
  }
}
