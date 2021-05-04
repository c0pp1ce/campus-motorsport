import 'package:campus_motorsport/services/color_services.dart';
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
  final double? elevation;
  final BorderRadius? radius;

  /// If loading, the button will be disabled.
  final bool? loading;

  /// Set to true, if no [gradient] is given and the standard gradient should not be drawn.
  ///
  /// Has no effect when a [gradient] is given.
  final bool? noGradient;

  /// Standard value. Can be overwritten by [radius].
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
    this.elevation,
    this.radius,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (loading ?? false) ? null : onPressed,
      style: _style(context),
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius ?? _borderRadius,
          gradient: (loading ?? false) ? null : gradient ?? _gradient(context),
          color: (loading ?? false)
              ? ColorServices.brighten(
                  Theme.of(context).colorScheme.surface, 35)
              : backgroundColor ?? null,
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 50, minHeight: 35),
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

  ButtonStyle _style(BuildContext context) {
    return ButtonStyle(
      elevation: MaterialStateProperty.all<double>(elevation ?? 0),
      minimumSize: MaterialStateProperty.all<Size>(const Size(50, 35)),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: radius ?? _borderRadius)),
      foregroundColor: MaterialStateProperty.all<Color>(
          primary ?? Theme.of(context).colorScheme.onPrimary),
      overlayColor: MaterialStateProperty.all<Color>(
          primary?.withOpacity(0.15) ??
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.15)),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(0.0)),
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
