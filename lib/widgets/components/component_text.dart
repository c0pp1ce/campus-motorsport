import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == text.
class ComponentText extends StatelessWidget {
  const ComponentText({
    required this.dataInput,
    this.previousData,
    this.minLines = 1,
    this.maxLines = 3,
    this.enabled = true,
    this.textInputType = TextInputType.multiline,
    this.highlightInput = false,
    this.validate,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final DataInput? previousData;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final TextInputType textInputType;
  final bool highlightInput;
  final String? Function(String?)? validate;

  @override
  Widget build(BuildContext context) {
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
        CMTextField(
          initialValue: dataInput.data,
          onSaved: (value) {
            dataInput.data = value;
          },
          minLines: minLines,
          maxLines: maxLines,
          enabled: enabled,
          textInputType: textInputType,
          validate: enabled
              ? validate ??
                  (value) => Validators().validateNotEmpty(value, 'Feld')
              : null,
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
            '${previousData!.data}',
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
