import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/routes/custom_router.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/utils/size_config.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/themes/color_themes.dart';
import 'package:campus_motorsport/themes/text_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  /// Remark : Might not work on some iOS devices.
  /// For possible fix see: https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

/// Provider for controllers which need to be available globally.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Initialize the size values only once.
    SizeConfig().init(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TokenController(),
        ),
      ],
      child: MyMaterialApp(),
    );
  }
}

/// General app settings.
class MyMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColorTheme.darkTheme.surface,
      ),
      child: MaterialApp(
        title: 'Campus Motorsport',
        theme: ThemeData(
          colorScheme: AppColorTheme.darkTheme,
          textTheme: AppTextTheme.theme,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          applyElevationOverlayColor: true,
        ),
        onGenerateRoute: CustomRouter.generateRoute,
        initialRoute: homeRoute,
        debugShowCheckedModeBanner: false,
        //checkerboardRasterCacheImages: true,
        //checkerboardOffscreenLayers: true,
      ),
    );
  }
}
