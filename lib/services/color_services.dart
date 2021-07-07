import 'package:flutter/material.dart';

/// Manipulate colors as needed.
///
/// Taken from: https://stackoverflow.com/questions/58360989/programmatically-lighten-or-darken-a-hex-color-in-dart
/// (last visited 02.04.2021).
/// Author: https://stackoverflow.com/users/2083587/mr-mmmmore
class ColorServices {
  static Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  static Color brighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }
}
