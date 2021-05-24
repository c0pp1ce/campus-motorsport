import 'package:campus_motorsport/utilities/size_config.dart';

import 'package:flutter/material.dart';

/// Handles displaying the logo.
class CMLogo extends StatelessWidget {
  const CMLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth * 0.8,
      child: Image.asset('assets/images/logo_white.png'),
    );
  }
}