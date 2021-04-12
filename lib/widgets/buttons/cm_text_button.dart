import 'package:flutter/material.dart';

/// Simple [TextButton] which can have gradient background and a loading indicator.
///
/// Code based on https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/text_button.dart (last visited: 02.04.2021).
class CMTextButton extends StatelessWidget {
  final Widget child;
  final void Function()? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final Color? primary;
  final Color? backgroundColor;
  final bool? loading;

  /// Set to true, if no [gradient] is given and the standard gradient should not be drawn.
  ///
  /// Has no effect when a [gradient] is given.
  final bool? noGradient;

  final BorderRadius _borderRadius = BorderRadius.circular(10.0);

  CMTextButton({
    required this.child,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.primary,
    this.backgroundColor,
    this.loading,
    this.noGradient,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        elevation: 0,
        minimumSize: Size(100, 35),
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadius,
        ),
        padding: const EdgeInsets.all(0.0),
        primary: primary ?? Theme.of(context).colorScheme.onPrimary,
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: gradient ?? _gradient(context),
          color: backgroundColor ?? null,
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 100, minHeight: 36),
          width: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              child,
              if (loading ?? false) ..._loadingIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _loadingIndicator(BuildContext context) {
    return [
      const SizedBox(
        width: 5.0,
      ),
      SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(
          strokeWidth: 1.2,
          valueColor: AlwaysStoppedAnimation<Color>(
              primary ?? Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    ];
  }

  LinearGradient? _gradient(BuildContext context) {
    if ((noGradient ?? false)) {
      return null;
    }
    return LinearGradient(
      colors: <Color>[
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primaryVariant,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
