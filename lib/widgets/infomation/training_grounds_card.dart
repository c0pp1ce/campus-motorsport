import 'package:campus_motorsport/models/training_ground.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_image_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:flutter/material.dart';

class TrainingGroundCard extends StatelessWidget {
  const TrainingGroundCard({
    required this.trainingGround,
    Key? key,
  }) : super(key: key);

  final TrainingGround trainingGround;

  @override
  Widget build(BuildContext context) {
    final Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CMLabel(
          label: trainingGround.name,
        ),
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        CMImagePicker(
          imageFile: trainingGround.image,
          enabled: false,
          heroTag: trainingGround.name,
        ),
      ],
    );

    return SimpleCard(
      margin: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
      child: child,
    );
  }
}
