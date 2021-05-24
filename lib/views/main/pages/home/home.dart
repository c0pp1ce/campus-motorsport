import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/views/main/pages/home/overview.dart';
import 'package:campus_motorsport/views/main/pages/home/overview_context.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Main view.
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = context.watch<HomeProvider>();
    switch (homeProvider.currentPage) {
      case HomePage.overview:
        return Overview();
      case HomePage.attendanceList:
        return MainView(
          title: Text("Anwesenheitsliste"),
          child: Container(),
        );
    }
  }
}

/// Right drawer.
class HomeContext extends StatelessWidget {
  const HomeContext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = context.watch<HomeProvider>();
    switch (homeProvider.currentPage) {
      case HomePage.overview:
        return OverviewContext();
      case HomePage.attendanceList:
        return ContextDrawer();
    }
  }
}

/// Left drawer.
class HomeSecondary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
