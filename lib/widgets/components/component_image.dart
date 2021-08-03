import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_image_picker.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == image.
class ComponentImage extends StatelessWidget {
  const ComponentImage({
    required this.dataInput,
    this.enabled = true,
    this.highlightInput = false,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final bool enabled;
  final bool highlightInput;

  @override
  Widget build(BuildContext context) {
    assert(dataInput.data is CMImage || dataInput.data == null,
        'Wrong data format.');
    dataInput.data ??= CMImage();

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
        CMImagePicker(
          imageFile: dataInput.data,
          enabled: enabled,
          heroTag: '${dataInput.name}image',
        ),
      ],
    );
  }
}
