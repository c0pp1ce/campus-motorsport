import 'package:flutter/material.dart';

import 'package:campus_motorsport/models/route_arguments/login_arguments.dart';
import 'package:campus_motorsport/views/login/login_view.dart';
import 'package:campus_motorsport/views/registration/registration_view.dart';


import 'package:campus_motorsport/routes/routes.dart';

/// Maps route names to views.
class CustomRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => placeholder(settings.name ?? 'NO ROUTE NAME'),
          settings: settings,
        );

      case loginRoute:
        if (settings.arguments != null) {
          try {
            return MaterialPageRoute(
              builder: (_) => LoginView(
                arguments: settings.arguments as LoginArguments,
              ),
              settings: settings,
            );
          } on Exception catch (e) {
            print(e);
            return MaterialPageRoute(
              builder: (_) => LoginView(),
              settings: settings,
            );
          }
        } else {
          return MaterialPageRoute(
            builder: (_) => LoginView(),
            settings: settings,
          );
        }

      case registerRoute:
        return MaterialPageRoute(
          builder: (_) => RegistrationView(settings.arguments as ImageProvider),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => routeNotFound(settings.name ?? 'NO ROUTE NAME'),
          settings: settings,
        );
    }
  }

  static Widget placeholder(String route) {
    return Scaffold(
      body: Center(
        child: Text('Placeholder for $route.'),
      ),
    );
  }

  static Widget routeNotFound(String route) {
    return Scaffold(
      body: Center(
        child: Text('Router could not find route $route.'),
      ),
    );
  }
}
