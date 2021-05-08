import 'package:flutter/material.dart';

/// The middle view of the stacked UI.
///
/// The child is placed inside a [Scaffold] with an [AppBar].
/// In order to connect this view to the [ContextDrawer] a state management solution
/// like Provider or BloC is recommended.
class MainView extends StatelessWidget {
  /// The Appbar title.
  final Widget? title;

  /// The leading widget inside the Appbar.
  final Widget? leading;

  /// The main content of the view.
  final Widget child;

  /// Should be the same for any instance.
  static const double appBarElevation = 2;

  const MainView({
    this.title,
    this.leading,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: leading,
          elevation: appBarElevation,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              top: const Radius.circular(15.0),
            ),
          ),
          title: title,
        ),
        body: Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 5,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: child,
          ),
        ),
      ),
    );
  }
}
