import 'package:flutter/widgets.dart';

/// Provides screen size and (safe)block sizes.
///
/// Use it to create a responsive design. A blocks height and width are 1% of
/// the corresponding screen dimension. Therefore a block is not square in most
/// cases.
///
/// 1. SizeConfig().init(context);  in your build() method.
/// 2. SizeConfig.screenWidth       etc. where needed.
///
/// Based on : https://medium.com/flutter-community/flutter-effectively-scale-ui-according-to-different-screen-sizes-2cb7c115ea0a
/// (last visited 02.04.2021).
class SizeConfig {
  static late MediaQueryData _mediaQueryData;

  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;

  static Orientation orientation = Orientation.portrait;

  /// Global style variables
  static const double basePadding = 10.0;
  static const double baseBorderRadius = 15.0;
  static const double baseBackgroundElevation = 5.0;
  static const double iconButtonSplashRadius = 25;
  static const int darkenTextColorBy = 40;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    orientation = _mediaQueryData.orientation;
  }
}
