import 'dart:math';

import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:campus_motorsport/widgets/home/overview/app_statistics.dart';

import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({
    Key? key,
  }) : super(key: key);

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      title: showAppBarTitle ? Text("Übersicht") : null,
      appBarShadowColor: showAppBarTitle ? null : Colors.transparent,
      backgroundElevation: 3,
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildHeaderBackground(context),
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppStatistics(
                    vehicleCount: 5,
                    partCount: 3,
                    userCount: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Container with app bar color so that when there occurs an overscroll
  /// at the top no color difference is seen (background of the body is slightly
  /// darker).
  Widget _buildHeaderBackground(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: ElevationOverlay.applyOverlay(
          context,
          Theme.of(context).colorScheme.surface,
          MainView.appBarElevation,
        ),
        height: _scrollController.hasClients
            ? max<double>(0, 140 - _scrollController.offset)
            : 140,
      ),
    );
  }

  bool get showAppBarTitle {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 15) {
        return true;
      }
    }
    return false;
  }
}
