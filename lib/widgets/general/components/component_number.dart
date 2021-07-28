import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/widgets/general/components/component_text.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == number.
class ComponentNumber extends StatelessWidget {
  const ComponentNumber({
    required this.dataInput,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ComponentText(
      dataInput: dataInput,
      minLines: 1,
      maxLines: 1,
      enabled: enabled,
      textInputType: TextInputType.number,
    );
  }
}
