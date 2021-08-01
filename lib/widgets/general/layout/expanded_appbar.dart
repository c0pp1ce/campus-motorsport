import 'dart:math';

import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';

/// A layout preset for the StackedUI MainView.
class ExpandedAppBar extends StatefulWidget {
  const ExpandedAppBar({
    required this.appbarTitle,
    required this.appbarChild,
    this.body = const SizedBox(),
    this.expandedHeight = 150,
    this.offsetBeforeTitleShown = 20,
    this.titleAlwaysVisible = false,
    this.onRefresh,
    this.loadingListener,
    this.actions,
    Key? key,
  }) : super(key: key);

  /// The title is shown when the appbars expanded space is not visible.
  final Widget appbarTitle;

  final bool titleAlwaysVisible;

  /// The child is placed inside the expanded appbar space.
  final Widget appbarChild;

  /// Main content of the view.
  final Widget body;

  final List<Widget>? actions;

  /// If given pull to refresh will be enabled.
  final Future<void> Function()? onRefresh;

  /// To make the loading state available.
  final void Function(bool)? loadingListener;

  final double expandedHeight;
  final double offsetBeforeTitleShown;

  @override
  _ExpandedAppBarState createState() => _ExpandedAppBarState();
}

class _ExpandedAppBarState extends State<ExpandedAppBar> {
  late ScrollController _scrollController;
  late double currentExpandedHeight;

  /// Stores the latest appbar state to avoid unnecessary rebuilds.
  late bool _showAppbarTitle;

  // Static configurations.
  static const double elevation = SizeConfig.baseBackgroundElevation - 3;

  @override
  void initState() {
    _showAppbarTitle = widget.titleAlwaysVisible;
    currentExpandedHeight = widget.expandedHeight;

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      final double newHeight =
          max<double>(0, widget.expandedHeight - _scrollController.offset);
      _scrollListener(newHeight);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      title: _showAppbarTitle || widget.titleAlwaysVisible
          ? widget.appbarTitle
          : null,
      appBarShadowColor: _showAppbarTitle ? null : Colors.transparent,
      backgroundElevation: elevation,
      actions: widget.actions,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildHeaderBackground(context),
          if (widget.onRefresh != null)
            RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              strokeWidth: 3,
              edgeOffset: -40,
              onRefresh: () async {
                if (widget.loadingListener != null) {
                  widget.loadingListener!(true);
                }
                await Future.delayed(Duration(milliseconds: 500));
                await widget.onRefresh!();
                if (widget.loadingListener != null) {
                  widget.loadingListener!(false);
                }
              },
              child: _buildContent(context, true),
            ),
          if (widget.onRefresh == null) _buildContent(context, false),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool refresh) {
    return SizedBox(
      height:  double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            _buildAppBarChild(context),
            widget.body,
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
        height: currentExpandedHeight,
      ),
    );
  }

  /// The widget that gets shown in the expanded appbar space.
  Widget _buildAppBarChild(BuildContext context) {
    /// Clip shadow on top side.
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      child: Container(
        height: widget.expandedHeight,

        /// Same color as rest of the body.
        color: ElevationOverlay.applyOverlay(
          context,
          Theme.of(context).colorScheme.surface,
          elevation,
        ),

        /// Padding to not clip shadow on the bottom side.
        padding: const EdgeInsets.only(bottom: 20),
        child: RepaintBoundary(
          child: Material(
            /// Color of the header part == Color of the app bar.
            /// Creates the shadow.
            color: Theme.of(context).colorScheme.surface,
            elevation: MainView.appBarElevation,
            shadowColor:
                ColorServices.brighten(Theme.of(context).shadowColor, 20),
            child: widget.appbarChild,
          ),
        ),
      ),
    );
  }

  void _scrollListener(double newHeight) {
    if (_showAppbarTitle != _appbarCollapsed) {
      setState(() {
        _showAppbarTitle = _appbarCollapsed;
      });

      /// Scroll down && scroll distance large enough
    } else if (newHeight > currentExpandedHeight &&
        newHeight - (widget.expandedHeight - 3) > currentExpandedHeight) {
      setState(() {
        currentExpandedHeight = newHeight;
      });

      /// Scroll up
    } else if (newHeight < currentExpandedHeight) {
      setState(() {
        currentExpandedHeight = newHeight;
      });
    }
  }

  bool get _appbarCollapsed {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > widget.offsetBeforeTitleShown) {
        return true;
      }
    }
    return false;
  }
}
