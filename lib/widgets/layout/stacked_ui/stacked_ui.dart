import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/navigation_drawer.dart';
import 'package:flutter/material.dart';

enum SlideDirection { right, left }

class StackedUI extends StatefulWidget {
  /// The visible width of the main view when it is slided out of view.
  final double slidedWidth;

  final Widget mainView;

  /// Only tested for usage of [NavigationDrawer].
  final Widget navigationDrawer;

  /// Only tested for usage of [ContextDrawer].
  final Widget contextDrawer;

  StackedUI({
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
  late double maxSlide;
  late AnimationController animationController;
  bool mainViewOpen = true;
  bool sideViewOpen = false;
  bool leftSideOpen = false;
  bool rightSideOpen = false;
  SlideDirection? slideDirection;

  /// Index of the IndexedStack used for navigation & context widgets.
  int _index = 0;

  @override
  void initState() {
    super.initState();

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    SizeConfig().init(context);
    maxSlide = SizeConfig.screenWidth - widget.slidedWidth;
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        rightSideOpen = true;
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

    if ((mainViewOpen && slideDirection != null) || sideViewOpen) {
      double delta = (details.primaryDelta ?? 0) / maxSlide;
      animationController.value += delta;
      return;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (slideDirection != null) {
      leftSideOpen = slideDirection == SlideDirection.left;
      rightSideOpen = slideDirection == SlideDirection.right;
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

    if (details.velocity.pixelsPerSecond.dx.abs() >= 360) {
      double visualVelocity =
          details.velocity.pixelsPerSecond.dx / SizeConfig.screenWidth;

      /// Adjust velocity to negative maxSlide value.
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

abstract class StackedChild extends StatelessWidget {
  final Widget mainChild;
  final Widget contextChild;

  StackedChild({required this.mainChild, required this.contextChild, Key? key})
      : super(key: key);
}
