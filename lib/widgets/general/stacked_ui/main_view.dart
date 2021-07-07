import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

/// The middle view of the stacked UI.
///
/// The child is placed inside a [Scaffold] with an [AppBar].
/// In order to connect this view to the [ContextDrawer] a state management solution
/// like Provider or BloC is recommended.
class MainView extends StatelessWidget {
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
  static const double appBarElevation = 5;

  /// background of the body.
  final Color? backgroundColor;

  /// Elevation of the body. Higher == lighter color.
  final double backgroundElevation;

  const MainView({
    this.title,
    this.flexibleSpace,
    this.leading,
    this.appBarColor,
    this.appBarShadowColor,
    this.backgroundColor,
    this.backgroundElevation = SizeConfig.baseBackgroundElevation,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: const Radius.circular(SizeConfig.baseBorderRadius),
      ),
    );

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
          ),
          body: Material(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            elevation: backgroundElevation,
            shadowColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
