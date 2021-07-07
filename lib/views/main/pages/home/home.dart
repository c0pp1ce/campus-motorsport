import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/views/main/pages/home/overview.dart';
import 'package:campus_motorsport/views/main/pages/home/overview_context.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
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
        return ContextDrawer(
          child: Material(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  LineIcons.infoCircle,
                ),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Auf dieser Seite kannst du sehen, wer gerade vor Ort ist.\n\n"
                        "Bitte ändere hier deinen Status, wenn du ankommst oder die Räume des Campus verlässt.",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

/// Left drawer.
class HomeSecondary extends StatelessWidget {
  const HomeSecondary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = context.watch<HomeProvider>();

    return Material(
      color: Colors.transparent,
      child: ListView(
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
