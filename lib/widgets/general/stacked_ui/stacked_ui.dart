import 'package:campus_motorsport/utilities/size_config.dart';

import 'package:flutter/material.dart';

/// Used to determine whether the [ContextDrawer] (right) or [NavigationDrawer] (left) should
/// be shown when the user performs a drag gesture.
enum SlideDirection { right, left }

class StackedUI extends StatefulWidget {
  const StackedUI({
    this.slidedWidth = 50,
    required this.mainView,
    required this.navigationDrawer,
    this.contextDrawer,
    this.allowSlideToContext = true,
    Key? key,
  }) : super(key: key);

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
  final Widget? contextDrawer;

  /// Manually set this to avoid slides if there are subpages without context drawer.
  final bool allowSlideToContext;

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
      duration: Duration(milliseconds: 200),
    );
    animationController.addStatusListener((status) {
      /// Used to apply the color overlay when main view is inactive.
      if (status == AnimationStatus.dismissed && !mainViewOpen) {
        setState(() {
          mainViewOpen = true;
        });
      } else if (status == AnimationStatus.completed && mainViewOpen) {
        setState(() {
          mainViewOpen = false;
        });
      }
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
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildIndexedStack(context),
              AnimatedBuilder(
                animation: animationController,
                child: BuildMainView(
                  toggle: toggle,
                  canToggle: animationController.isCompleted,
                  hasContextDrawer: widget.contextDrawer != null &&
                      widget.allowSlideToContext,
                  mainView: widget.mainView,
                  mainViewOpen: mainViewOpen,
                ),
                builder: (context, child) {
                  final double slide = maxSlide * animationController.value;
                  return Transform(
                    transform: Matrix4.identity()..translate(slide),
                    child: child,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IndexedStack _buildIndexedStack(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: <Widget>[
        widget.navigationDrawer,
        if (widget.contextDrawer != null && widget.allowSlideToContext)
          widget.contextDrawer!,
      ],
    );
  }

  /// Opens navigation menu or the main view.
  ///
  /// Does not open the context menu.
  void toggle([bool onlyOpenMain = false]) {
    if (animationController.isDismissed && !onlyOpenMain) {
      if (maxSlide < 0) {
        maxSlide = -maxSlide;
        leftSideOpen = false;
        setState(() {
          _index = 0;
        });
      }
      animationController.forward();
    } else if (animationController.isCompleted) {
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
      final double delta = details.primaryDelta ?? 0;
      setState(() {
        if (delta < 0 &&
            widget.contextDrawer != null &&
            widget.allowSlideToContext) {
          slideDirection = SlideDirection.left;
          if (maxSlide > 0) {
            maxSlide = -maxSlide;
          }
          _index = 1;
        } else if (delta > 0) {
          slideDirection = SlideDirection.right;
          if (maxSlide < 0) {
            maxSlide = -maxSlide;
          }
          _index = 0;
        }
      });
    }

    /// maxSlide correctly set in first call of drag update.
    /// No need to further alter any values to get the desired drag feeling.
    if ((mainViewOpen && slideDirection != null) || sideViewOpen) {
      final double delta = (details.primaryDelta ?? 0) / maxSlide * 1.4;
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

class BuildMainView extends StatelessWidget {
  const BuildMainView({
    required this.toggle,
    required this.canToggle,
    required this.hasContextDrawer,
    required this.mainView,
    required this.mainViewOpen,
    Key? key,
  }) : super(key: key);

  final void Function() toggle;
  final bool canToggle;
  final bool hasContextDrawer;
  final bool mainViewOpen;
  final Widget mainView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canToggle ? toggle : null,
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: mainView,
          ),
          if (mainViewOpen && hasContextDrawer)
            RepaintBoundary(
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.translate(
                  offset: const Offset(13, 0),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: SizeConfig.baseBackgroundElevation,
                      borderRadius: BorderRadius.circular(30),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!mainViewOpen)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SizeConfig.baseBorderRadius),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
