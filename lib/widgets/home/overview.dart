import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Overview extends StatelessWidget {
  final int vehicleCount;
  final int partCount;
  final int userCount;

  const Overview({
    required this.vehicleCount,
    required this.partCount,
    required this.userCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Text(
            "App Statistiken",
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Card(
          elevation: 5,
          color: ElevationOverlay.applyOverlay(
              context, Theme.of(context).colorScheme.surface, 10),
          margin: EdgeInsets.zero,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _buildCounter(
                      "Fahrzeuge", LineIcons.car, vehicleCount, context),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildCounter(
                      "Teile", LineIcons.tools, partCount, context),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildCounter(
                      "User", LineIcons.users, userCount, context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(
      String title, IconData icon, int count, BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "$count",
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: color,
                  ),
            ),
          ],
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return VerticalDivider(
      color: Theme.of(context).colorScheme.primary,
      thickness: 1.2,
      width: 10,
      indent: 10,
      endIndent: 10,
    );
  }
}
