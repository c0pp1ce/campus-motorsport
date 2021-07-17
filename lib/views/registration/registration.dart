import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/background/background_image.dart';
import 'package:campus_motorsport/widgets/registration/form_fields.dart';

import 'package:flutter/material.dart';

class Registration extends StatelessWidget {
  const Registration({
    required this.backgroundImage,
    Key? key,
  }) : super(key: key);

  final ImageProvider backgroundImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: BackgroundImage(
        image: backgroundImage,
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SizeConfig.basePadding * 2,
                ),
                child: FormFields(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
