import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/vehicle_components/data_input.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/image_picker.dart';
import 'package:flutter/material.dart';

/// Used to display DataInput with type == image.
class ComponentImage extends StatelessWidget {
  const ComponentImage({
    required this.dataInput,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final DataInput dataInput;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    assert(dataInput.data is CMImage || dataInput.data == null,
        'Wrong data format.');
    dataInput.data ??= CMImage();

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
        CMImagePicker(
          imageFile: dataInput.data,
          enabled: enabled,
          heroTag: '${dataInput.name}image',
        ),
      ],
    );
  }
}
