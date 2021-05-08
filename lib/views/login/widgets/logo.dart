import 'package:flutter/material.dart';

import 'package:campus_motorsport/utils/size_config.dart';

/// Handles displaying the logo.
class Logo extends StatelessWidget {
  Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth * 0.8,
      child: Image.asset('assets/images/logo_white.png'),
    );
  }
}