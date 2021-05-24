import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AppStatistics extends StatelessWidget {
  final int vehicleCount;
  final int partCount;
  final int userCount;

  const AppStatistics({
    required this.vehicleCount,
    required this.partCount,
    required this.userCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Clip shadow on top side.
    return ClipRRect(
      /// Same color as rest of the body.
      child: Container(
        height: 150,
        color: ElevationOverlay.applyOverlay(
          context,
          Theme.of(context).colorScheme.surface,
          3,
        ),

        /// Padding to not clip shadow on the bottom side.
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          child: Material(
            /// Color of the header part == Color of the app bar.
            /// Creates the shadow.
            color: Theme.of(context).colorScheme.surface,
            elevation: MainView.appBarElevation,
            child: Column(
              /// Actual content of the header.
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  child: Text(
                    "Übersicht",
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 80,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(
      String title, IconData icon, int count, BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurface;
    return Container(
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
      ),
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
