import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/main_view.dart';
import 'package:campus_motorsport/widgets/home/feed.dart';
import 'package:campus_motorsport/widgets/home/overview.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentPage = "Übersicht"; // TODO : Connect with provider.

  @override
  Widget build(BuildContext context) {
    return MainView(
      title: Text(currentPage),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: <Widget>[
            Overview(
              vehicleCount: 4,
              partCount: 33,
              userCount: 5,
            ),
            _spacer(1),
            Feed(),
          ],
        ),
      ),
    );
  }

  Widget _spacer(int factor) {
    return SizedBox(
      height: 10.0 * factor,
    );
  }
}

class HomeContext extends StatefulWidget {
  HomeContext({Key? key}) : super(key: key);

  @override
  HomeContextState createState() => HomeContextState();
}

class HomeContextState extends State<HomeContext> {
  bool showMaintenances = true;
  bool showEvents = true;

  @override
  Widget build(BuildContext context) {
    return ContextDrawer(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Feed Filter",
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.start,
              ),
              _buildFilterChips(context),
              Divider(
                thickness: 1.2,
                indent: 10,
                endIndent: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              _buildInfo(context,
                  "Wähle im Filter aus welche Arten von Aktivitäten angezeigt werden sollen.", LineIcons.filter),
              const SizedBox(
                height: 10,
              ),
              _buildInfo(context,
                  "Tippe auf einen Eintrag im Feed um zur Detailansicht zu gelangen.", LineIcons.infoCircle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilterChip(
          label: Text(
            'Wartungen',
            style: getChipTextStyle(showMaintenances, context),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: showMaintenances,
          onSelected: (selected) {
            setState(() {
              showMaintenances = selected;
            });
          },
        ),
        FilterChip(
          label: Text(
            'Events',
            style: getChipTextStyle(showEvents, context),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: showEvents,
          onSelected: (selected) {
            setState(() {
              showEvents = selected;
            });
          },
        ),
      ],
    );
  }

  TextStyle? getChipTextStyle(bool selected, BuildContext context) {
    return Theme.of(context).textTheme.bodyText2?.copyWith(
        color: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface);
  }

  Widget _buildInfo(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon),
        Container(
          width: SizeConfig.safeBlockHorizontal * 65,
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
