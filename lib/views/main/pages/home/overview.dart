import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/home/overview/app_statistics.dart';

import 'package:flutter/material.dart';

/// The overview screen is the first screen a user sees after the login.
/// Its part of the home screen.
class Overview extends StatelessWidget {
  const Overview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      expandedHeight: 150,
      appbarTitle: Text('Übersicht'),
      appbarChild: AppStatistics(
        vehicleCount: 5,
        partCount: 3,
        userCount: 1,
      ),
    );
  }
}
