import 'package:campus_motorsport/views/login/login.dart';
import 'package:campus_motorsport/views/login_problems/login_problems.dart';
import 'package:campus_motorsport/views/main/main_navigator.dart';
import 'package:campus_motorsport/views/registration/registration.dart';
import 'package:campus_motorsport/main.dart';
import 'package:campus_motorsport/routes/routes.dart';

import 'package:flutter/material.dart';

/// Maps route names to views.
class CustomRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainRoute:
        return MaterialPageRoute(
          builder: (_) => MainNavigator(),
          settings: settings,
        );

      case initAppRoute:
        return MaterialPageRoute(
          builder: (_) => InitApp(),
          settings: settings,
        );

      case loginRoute:
        if (settings.arguments != null) {
          return MaterialPageRoute(
            builder: (_) => Login(
              fadeIn: settings.arguments! as bool,
            ),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => Login(),
            settings: settings,
          );
        }

      case registerRoute:
        if (settings.arguments != null) {
          return MaterialPageRoute(
            builder: (_) => Registration(
              backgroundImage: settings.arguments! as ImageProvider,
            ),
            settings: settings,
          );
        } else {
          print('Missing route arguments.');
          return routeNotFound(settings.name ?? 'Registration');
        }

      case loginProblemsRoute:
        if (settings.arguments != null) {
          return MaterialPageRoute(
            builder: (_) => LoginProblems(
              backgroundImage: settings.arguments! as ImageProvider,
            ),
            settings: settings,
          );
        } else {
          print('Missing route arguments.');
          return routeNotFound(settings.name ?? 'Login problems');
        }

      default:
        return routeNotFound(settings.name ?? 'NO ROUTE NAME');
    }
  }

  static Widget placeholder(String route) {
    return Scaffold(
      body: Center(
        child: Text('Placeholder for $route.'),
      ),
    );
  }

  static MaterialPageRoute routeNotFound(String route) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Text('Router could not find route $route.'),
        ),
      );
    });
  }
}
