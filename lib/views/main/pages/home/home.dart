import 'package:campus_motorsport/provider/home/home_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/home/overview.dart';
import 'package:campus_motorsport/views/main/pages/home/overview_context.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';

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
        return ExpandedAppBar(
          offsetBeforeTitleShown: 35,
          appbarTitle: Text("Anwesenheitsliste"),
          appbarChild: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ExpandedTitle(
                title: "Anwesenheitsliste",
                margin: EdgeInsets.zero,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Derzeit vor Ort",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 16,
                        ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) => null,
                  ),
                ],
              ),
            ],
          ),
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
                  child: SimpleCard(
                    elevation: SizeConfig.baseBackgroundElevation - 3,
                    margin: const EdgeInsets.only(left: 5),
                    child: Text(
                      "Auf dieser Seite kannst du sehen, wer gerade vor Ort ist.\n\n"
                      "Bitte ändere hier deinen Status, wenn du ankommst oder die Räume des Campus verlässt.",
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
