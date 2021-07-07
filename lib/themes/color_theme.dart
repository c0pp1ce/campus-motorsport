import 'package:flutter/material.dart';

/// Defines the dark and light color themes for the app.
class AppColorTheme {
  // TODO : Adjust light theme if wanted.
  static final ColorScheme lightTheme = ColorScheme(
    primary: Color(0xff1173D4),
    primaryVariant: Color(0xff2E47B2),
    onPrimary: Colors.white,
    secondary: Color(0xff11D4D4),
    secondaryVariant: Color(0xff00A2A3),
    onSecondary: Colors.black,
    background: Color(0xffE3F8EB),
    onBackground: Colors.black,
    error: Colors.amber,
    onError: Colors.black,
    surface: Color(0xffF5F5F5),
    onSurface: Colors.black,
    brightness: Brightness.light,
  );

  static final ColorScheme darkTheme = ColorScheme(
    primary: Color(0xff66B8AA), // Corporate Design Highlight light
    primaryVariant: Color(0xff33887B), // Corporate Design Highlight
    //primary: Color(0xff0072CA), // Corporate Design Blue
    //primaryVariant: Color(0xff004899), // Corporate Design Blue dark
    //primary: Color(0xff70E1CE), // old
    //primaryVariant: Color(0xff37AF9D), // old
    onPrimary: Colors.black, // switch to white when using the blue as primary
    secondary: Color(0xffE8E8E8),
    secondaryVariant: Color(0xffB6B6B6),
    onSecondary: Colors.black,
    background: Color(0xff121212),
    onBackground: Colors.white,
    error: Colors.amber,
    onError: Colors.black,
    surface: Color(0xff121212),
    //surface: Color(0xff00192F),
    onSurface: Colors.white,
    brightness: Brightness.dark,
  );
}
