import 'package:campus_motorsport/provider/components/components_provider.dart';
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

  /// [[users, parts, vehicles]]
  Future<List<int>> _getData(BuildContext context) async {
    final List<int> counts = List.filled(3, 0);
    await context.read<UsersProvider>().users.then(
          (value) => counts[0] = value.length,
        );
    await context.read<ComponentsProvider>().components.then(
          (value) => counts[1] = value.length,
        );
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    /// Watch inside of the function not possible.
    context.watch<UsersProvider>();
    context.watch<ComponentsProvider>();


    return ExpandedAppBar(
      expandedHeight: 150,
      appbarTitle: const Text('Übersicht'),
      appbarChild: FutureBuilder<List<int>?>(
        future: _getData(context),
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
            partCount: snapshot.data![1],
            userCount: snapshot.data![0],
          );
        },
      ),
    );
  }
}
