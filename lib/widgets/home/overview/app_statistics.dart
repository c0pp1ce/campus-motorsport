import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AppStatistics extends StatelessWidget {
  const AppStatistics({
    required this.vehicleCount,
    required this.partCount,
    required this.userCount,
    Key? key,
  }) : super(key: key);

  final int vehicleCount;
  final int partCount;
  final int userCount;

  @override
  Widget build(BuildContext context) {
    /// Clip shadow on top side.
    return Column(
      /// Actual content of the header.
      children: <Widget>[
        ExpandedTitle(
          title: 'Übersicht',
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: _buildCounter(
                  'Fahrzeuge',
                  LineIcons.car,
                  vehicleCount,
                  context,
                ),
              ),
              _buildDivider(context),
              Expanded(
                child: _buildCounter(
                  'Teile',
                  LineIcons.tools,
                  partCount,
                  context,
                ),
              ),
              _buildDivider(context),
              Expanded(
                child: _buildCounter(
                  'User',
                  LineIcons.users,
                  userCount,
                  context,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(
    String title,
    IconData icon,
    int count,
    BuildContext context,
  ) {
    final Color color = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                '$count',
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
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return VerticalDivider(
      color: Theme.of(context).colorScheme.primary,
      thickness: 1.2,
      width: 10,
      indent: 5,
      endIndent: 5,
    );
  }
}
