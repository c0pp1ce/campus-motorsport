import 'package:flutter/material.dart';

import 'package:campus_motorsport/utils/size_config.dart';

/// Handles displaying the logo.
class Logo extends StatelessWidget {
  Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: SizeConfig.orientation == Orientation.portrait
            ? SizeConfig.screenWidth / 1.3
            : SizeConfig.screenWidth / 2,
        child: Image.asset('assets/images/logo_white.png'),
      ),
    );
  }
}