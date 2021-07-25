import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

/// The middle view of the stacked UI.
///
/// The child is placed inside a [Scaffold] with an [AppBar].
/// In order to connect this view to the [ContextDrawer] a state management solution
/// like Provider or BloC is recommended.
class MainView extends StatelessWidget {
  const MainView({
    this.title,
    this.flexibleSpace,
    this.leading,
    this.appBarColor,
    this.appBarShadowColor,
    this.backgroundColor,
    this.backgroundElevation = SizeConfig.baseBackgroundElevation,
    required this.child,
    this.actions,
    Key? key,
  }) : super(key: key);

  /// The Appbar title.
  final Widget? title;

  final Widget? flexibleSpace;

  /// The leading widget inside the Appbar.
  final Widget? leading;

  /// The main content of the view.
  final Widget child;

  /// Background color of the app bar.
  final Color? appBarColor;
  final Color? appBarShadowColor;

  /// Should be the same for any instance.
  static const double appBarElevation = SizeConfig.baseBackgroundElevation;

  /// background of the body.
  final Color? backgroundColor;

  /// Elevation of the body. Higher == lighter color.
  final double backgroundElevation;

  final List<Widget>? actions;

  static const RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(SizeConfig.baseBorderRadius),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: appBarElevation,
        shape: shape,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shadowColor: appBarShadowColor,
            automaticallyImplyLeading: false,
            leading: leading,
            elevation: appBarElevation,
            backgroundColor: appBarColor,
            shape: shape,
            title: title,
            flexibleSpace: flexibleSpace,
            actions: actions,
          ),
          body: Material(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            elevation: backgroundElevation,
            shadowColor: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
