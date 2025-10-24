import 'package:flutter/material.dart';
import 'package:trivia/ui/screens/home.dart';
import 'package:trivia/ui/screens/settings.dart';

class Routes {
  static const home = "/home";
  static const settings = "/settings";
  static const gameplay = "gameplay";
}

class AppRouter {
  static Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.home:
        return screen(widget: const HomeScreen());
      case Routes.settings:
        return screen(widget: const SettingsScreen());
      default:
        return null;
    }
  }
}

MaterialPageRoute screen({required Widget widget}) {
  return MaterialPageRoute(builder: (_) => widget);
}
