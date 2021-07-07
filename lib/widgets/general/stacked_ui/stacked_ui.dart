import 'package:campus_motorsport/utilities/size_config.dart';

import 'package:flutter/material.dart';

/// Used to determine whether the [ContextDrawer] (right) or [NavigationDrawer] (left) should
/// be shown when the user performs a drag gesture.
enum SlideDirection { right, left }

class StackedUI extends StatefulWidget {
  /// The visible width of the main view when it is slided out of view.
  ///
  /// Attention: Currently there is no way to adjust the [ContextDrawer] and
  /// [NavigationDrawer to match changes made to this width.
  final double slidedWidth;

  /// Middle view of the [StackedUI].
  final Widget mainView;

  /// Left view of the [StackedUI].
  ///
  /// Only tested for usage with [NavigationDrawer].
  final Widget navigationDrawer;

  /// Right view of the [StackedUI].
  ///
  /// Only tested for usage with [ContextDrawer].
  final Widget contextDrawer;

  const StackedUI({
    this.slidedWidth = 50,
    required this.mainView,
    required this.navigationDrawer,
    required this.contextDrawer,
    Key? key,
  }) : super(key: key);

  @override
  StackedUIState createState() => StackedUIState();
}

class StackedUIState extends State<StackedUI>
    with SingleTickerProviderStateMixin {
  /// Calculated based on [widget.slideWidth] and screen width.
  ///
  /// In order to have slides to left and right this value needs to switch between
  /// maxSlide and -maxSlide.
  late double maxSlide;
  late AnimationController animationController;
  bool mainViewOpen = true;
  bool sideViewOpen = false;

  /// Needed in order to determine if the velocity needs to be multiplied by -1
  /// This is due to the fact that in order to animate a swipe from right to left
  /// (which opens left side) maxSlide needs to be multiplied by -1.
  bool leftSideOpen = false;

  /// Only set if on [mainViewOpen] was true on drag start.
  SlideDirection? slideDirection;

  /// Index of the IndexedStack used for navigation & context widgets.
  /// 0 = [NavigationDrawer], 1 = [ContextDrawer].
  int _index = 0;

  @override
  void initState() {
    super.initState();

    maxSlide = SizeConfig.screenWidth - widget.slidedWidth;

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    animationController.addStatusListener((status) {
      /// Used to apply the color overlay when main view is inactive.
      setState(() {
        if (status == AnimationStatus.dismissed) {
          mainViewOpen = true;
        } else if (status == AnimationStatus.completed) {
          mainViewOpen = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          color: Theme.of(context).colorScheme.surface,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, _) {
              double slide = maxSlide * animationController.value;
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildIndexedStack(context),
                  _buildMainView(context, slide),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, double slide) {
    return Transform(
      transform: Matrix4.identity()..translate(slide),
      child: GestureDetector(
        onTap: animationController.isCompleted ? toggle : null,
        child: Stack(
          children: <Widget>[
            widget.mainView,
            if (!mainViewOpen)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: const Radius.circular(SizeConfig.baseBorderRadius),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IndexedStack _buildIndexedStack(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: <Widget>[
        widget.navigationDrawer,
        widget.contextDrawer,
      ],
    );
  }

  /// Opens navigation menu or the main view.
  ///
  /// Does not open the context menu.
  void toggle() {
    if (animationController.isDismissed) {
      if (maxSlide < 0) {
        maxSlide = -maxSlide;
        leftSideOpen = false;
        setState(() {
          _index = 0;
        });
      }
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  void _onDragStart(DragStartDetails details) {
    mainViewOpen = animationController.isDismissed;
    sideViewOpen = animationController.isCompleted;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    /// Only set slideDirection if a side menu is slided in.
    ///
    /// Only called on the first drag update after a drag end.
    if (mainViewOpen && slideDirection == null) {
      double delta = details.primaryDelta ?? 0;
      setState(() {
        if (delta < 0) {
          slideDirection = SlideDirection.left;
          if (maxSlide > 0) maxSlide = -maxSlide;
          _index = 1;
        } else if (delta > 0) {
          slideDirection = SlideDirection.right;
          if (maxSlide < 0) maxSlide = -maxSlide;
          _index = 0;
        }
      });
    }

    /// maxSlide correctly set in first call of drag update.
    /// No need to further alter any values to get the desired drag feeling.
    if ((mainViewOpen && slideDirection != null) || sideViewOpen) {
      double delta = (details.primaryDelta ?? 0) / maxSlide;
      animationController.value += delta;
      return;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (slideDirection != null) {
      leftSideOpen = slideDirection == SlideDirection.left;
    }

    /// No need for snapping the animation to an end state.
    if (animationController.isDismissed || animationController.isCompleted) {
      if (animationController.isDismissed) {
        sideViewOpen = false;
        mainViewOpen = true;
      } else {
        /// animationController.isCompleted
        sideViewOpen = true;
        mainViewOpen = false;
      }

      /// Reset slide direction, so that it will be set again on the next drag.
      slideDirection = null;
      return;
    }

    /// Snap into the current direction if the drag gesture is fast enough.
    /// Otherwise snap to the closest end state.
    if (details.velocity.pixelsPerSecond.dx.abs() >= 360) {
      double visualVelocity =
          details.velocity.pixelsPerSecond.dx / SizeConfig.screenWidth;

      /// Adjust velocity to the negative maxSlide value.
      if (slideDirection == SlideDirection.left || leftSideOpen) {
        visualVelocity = -visualVelocity;
      }
      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse(from: animationController.value);
    } else {
      animationController.forward(from: animationController.value);
    }

    /// Reset slide direction, so that it will be set again on the next drag.
    slideDirection = null;
  }
}