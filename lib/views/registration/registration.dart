import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/background/background_image.dart';
import 'package:campus_motorsport/widgets/registration/form_fields.dart';

import 'package:flutter/material.dart';

class Registration extends StatelessWidget {
  final ImageProvider backgroundImage;

  const Registration({
    required this.backgroundImage,
    Key? key,
  }) : super(key: key);

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
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: WillPopScope(
                  onWillPop: () async {
                    // TODO : If loading return false.
                    return true;
                  },
                  child: FormFields(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
