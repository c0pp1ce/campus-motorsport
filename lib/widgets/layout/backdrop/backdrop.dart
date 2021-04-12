import 'package:campus_motorsport/utils/size_config.dart';
import 'package:flutter/material.dart';

/// A layout with a backdrop and a panel (foreground).
///
/// Based on : https://github.com/CORDEA/flutter_backdrop_steps (last visited 12.04.2021).
/// Which is licensed under Apache License 2.0. http://www.apache.org/licenses/LICENSE-2.0
/// Changes have been made.
class Backdrop extends StatefulWidget {
  final Widget backdropChild;
  final Widget panelChild;

  /// The appbar title.
  final Widget title;

  /// The panel header, which is always visible.
  /// Has a fixed height of 40.0.
  final Widget? panelHeader;
  final List<Widget>? appBarActions;

  // Placed here so they can be seen from other widgets.
  static const double panelElevation = 12.0;
  static const BorderRadius panelBorderRadius = const BorderRadius.only(
    topLeft: const Radius.circular(16.0),
    topRight: const Radius.circular(16.0),
  );

  Backdrop(
      {required this.backdropChild,
      required this.panelChild,
      required this.title,
      this.panelHeader,
      this.appBarActions,
      Key? key})
      : super(key: key);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  /// Height of the foreground header which is always visible
  static const double _panelHeaderHeight = 40.0;

  /// For handling the swipes.
  double? _maxSlide;

  /// Key used to get position / height of the backdrop child to determine
  /// how far the panel slides when closed.
  GlobalKey _backdropChildKey = GlobalKey();

  /// Controller for animating the panel (foreground).
  AnimationController? _panelController;

  @override
  void initState() {
    super.initState();

    _panelController = new AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0, // initially closed.
      vsync: this,
    );
    _panelController!.addStatusListener((status) {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SizeConfig().init(context);
    _maxSlide = SizeConfig.screenHeight;
  }

  @override
  void dispose() {
    _panelController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.0,
        title: widget.title,
        leading: _buildMenuButton(context),
        actions: widget.appBarActions,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }

  /// Builds the stack of backdrop & foreground content.
  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> animation = _getPanelAnimation(constraints);
    return Container(
      height: constraints.biggest.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          _buildBackdrop(context),
          PositionedTransition(
            rect: animation,
            child: _buildPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0),
      key: _backdropChildKey,
      child: widget.backdropChild,
    );
  }

  Widget _buildPanel(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _isPanelVisible ? null : _onPanelDragStart,
      onVerticalDragUpdate: _isPanelVisible ? null : _onPanelDragUpdate,
      onVerticalDragEnd: _isPanelVisible ? null : _onPanelDragEnd,
      onTap: _isPanelVisible ? null : _onPanelTap,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: Backdrop.panelElevation,
        borderRadius: Backdrop.panelBorderRadius,
        child: Column(
          children: <Widget>[
            if (widget.panelHeader != null)
              Container(
                height: _panelHeaderHeight,
                child: widget.panelHeader,
              ),
            Expanded(
              child: widget.panelChild,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the button to open/close the backdrop.
  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        /// Execute the animation.
        _panelController!.fling(velocity: _isPanelVisible ? -1.0 : 1.0);
        setState(() {});
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.close_menu,
        progress: _panelController!.view,
      ),
    );
  }

  /// The animation of the foreground (panel).
  Animation<RelativeRect> _getPanelAnimation(BoxConstraints constraints) {
    double height = constraints.biggest.height;

    /// Get position & height of the backdrop child.
    RenderObject? boxObject =
        _backdropChildKey.currentContext?.findRenderObject();
    RenderBox? box;
    if (boxObject != null) {
      box = boxObject as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      height = position.dy + box.size.height;
      if (height > constraints.biggest.height) {
        height = constraints.biggest.height;
      }
    }

    /// The header should always be visible.
    final double top = height - _panelHeaderHeight;
    final double bottom = -_panelHeaderHeight;
    return RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _panelController!,
      curve: Curves.easeIn,
    ));
  }

  void _onPanelDragStart(DragStartDetails details) {
    // print("Panel drag start");
  }

  /// Calculate drag length
  void _onPanelDragUpdate(DragUpdateDetails details) {
    double? delta = details.primaryDelta;

    /// (_maxSlide! / 2) for faster slide feeling.
    _panelController!.value -= (delta ?? 0) / (_maxSlide! / 2);
  }

  /// Open the panel on tap.
  void _onPanelTap() {
    _panelController!.fling(velocity: 1.0);
  }

  /// Snap panel to open/closed.
  void _onPanelDragEnd(DragEndDetails details) {
    /// Panel fully opened or closed.
    if (_panelController!.isCompleted || _panelController!.isDismissed) {
      return;
    }
    _panelController!.fling(
      velocity: 1,
    );
  }

  /// Determine if the foreground is visible.
  bool get _isPanelVisible {
    final AnimationStatus status = _panelController!.status;
    return (status == AnimationStatus.completed ||
        status == AnimationStatus.forward);
  }
}
