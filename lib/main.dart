import 'package:campus_motorsport/routes/custom_router.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/themes/color_themes.dart';
import 'package:campus_motorsport/themes/text_theme.dart';


void main() {
  Paint.enableDithering = true;
  runApp(MyApp());
}

/// Provider for blocs which need to be available globally.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO : Insert blocs when needed everywhere.
    /*return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (BuildContext context) => ThemeBloc(),
        ),
      ],
      child: MyMaterialApp(),
    );*/
    return MyMaterialApp();
  }
}

/// General app settings.
class MyMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamStage',
      theme: ThemeData(
        colorScheme: AppColorTheme.darkTheme,
        textTheme: AppTextTheme.theme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: CustomRouter.generateRoute,
      initialRoute: loginRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
