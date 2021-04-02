import 'package:campus_motorsport/views/login/login_view.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/routes/routes.dart';

/// Maps route names to views.
class CustomRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => placeholder(settings.name ?? 'NO ROUTE NAME'),
        );

      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => LoginView(),
        );

      case registerRoute:
        return MaterialPageRoute(
          builder: (_) => placeholder(settings.name ?? 'NO ROUTE NAME'),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => routeNotFound(settings.name ?? 'NO ROUTE NAME'),
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