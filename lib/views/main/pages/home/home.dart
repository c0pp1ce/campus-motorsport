import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/views/main/pages/home/attendance_list.dart';
import 'package:campus_motorsport/views/main/pages/home/overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Main view.
class Home extends StatelessWidget {
  const Home({
    Key? key,
    required this.setIndex,
  }) : super(key: key);

  final Function(int) setIndex;

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = context.watch<HomeProvider>();
    switch (homeProvider.currentPage) {
      case HomePage.overview:
        return Overview(
          setIndex: setIndex,
        );
      case HomePage.attendanceList:
        return const AttendanceList();
    }
  }
}

/// Left drawer.
class HomeSecondary extends StatelessWidget {
  const HomeSecondary({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = context.watch<HomeProvider>();

    return Material(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: HomePage.values.map((page) {
          return ListTile(
            title: Text(
              page.pageName,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: homeProvider.currentPage == page
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
            onTap: () {
              homeProvider.switchTo(page);
            },
          );
        }).toList(),
      ),
    );
  }
}
