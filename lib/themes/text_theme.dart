import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the text theme used throughout the app.
///
/// Theme is mostly created by the type scale generator which can be found here:
/// https://material.io/design/typography/the-type-system.html#type-scale
class AppTextTheme {
  static final TextTheme theme = TextTheme(
    headline1: GoogleFonts.contrailOne(
      fontSize: 86,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
    ),
    headline2: GoogleFonts.contrailOne(
      fontSize: 53,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    headline3: GoogleFonts.contrailOne(
      fontSize: 43,
      fontWeight: FontWeight.w400,
    ),
    headline4: GoogleFonts.contrailOne(
      fontSize: 30,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    headline5: GoogleFonts.contrailOne(
      fontSize: 21,
      fontWeight: FontWeight.w400,
    ),
    headline6: GoogleFonts.contrailOne(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    subtitle1: GoogleFonts.contrailOne(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    subtitle2: GoogleFonts.contrailOne(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyText1: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyText2: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    button: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    caption: GoogleFonts.openSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    overline: GoogleFonts.openSans(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    ),
  );
}