import 'package:campus_motorsport/services/color_services.dart';
import 'package:flutter/material.dart';

/// A snackbar preset to display an error message.
class ErrorSnackBar {
  final String error;
  final String dismissLabel;

  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;

  final BorderRadius _borderRadius = BorderRadius.circular(5.0);

  ErrorSnackBar(
    this.error,
    this.dismissLabel, {
    this.backgroundColor,
    this.borderColor,
    this.elevation = 0,
  });

  SnackBar buildSnackbar(BuildContext context) {
    return SnackBar(
      content: Text(
        error,
        style: Theme.of(context).textTheme.bodyText2?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
      action: SnackBarAction(
        label: dismissLabel,
        textColor: Theme.of(context).colorScheme.onSurface,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      duration: Duration(seconds: 8),
      backgroundColor: backgroundColor ??
          Theme.of(context).colorScheme.surface.withOpacity(0.9),
      elevation: elevation,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: _borderRadius,
        side: BorderSide(
          color: borderColor ??
              ColorServices.darken(Theme.of(context).colorScheme.surface, 30),
        ),
      ),
    );
  }
}
