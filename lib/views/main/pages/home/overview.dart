import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/user_management/users_provider.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/home/overview/app_statistics.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appbarTitle: const Text('Übersicht'),
      appbarChild: FutureBuilder<List<User>?>(
        future: context.watch<UsersProvider>().users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppStatistics(
              loading: true,
              vehicleCount: 0,
              partCount: 0,
              userCount: 0,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return AppStatistics(
              loading: false,
              vehicleCount: 0,
              partCount: 0,
              userCount: 0,
            );
          }

          return AppStatistics(
            loading: false,
            vehicleCount: 0,
            partCount: 0,
            userCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
