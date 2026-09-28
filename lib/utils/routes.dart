import 'package:flutter/material.dart';
import 'package:trivia/ui/screens/gameplay.dart';
import 'package:trivia/ui/screens/home.dart';
import 'package:trivia/ui/screens/settings.dart';

/// Named routes used across the app.
///
/// Every value is an absolute path so `pushNamed` and `onGenerateRoute` always
/// agree on the name (the gameplay route used to be the odd one out with no
/// leading slash).
class Routes {
  Routes._();

  static const String home = '/home';
  static const String settings = '/settings';
  static const String gameplay = '/gameplay';
}

/// The single route table for the app.
///
/// The route map used to live inline in `main.dart` and called
/// `builder!(context)` straight away, so any name it did not know - including
/// `Routes.gameplay`, which was never registered there - crashed with a
/// null-check error instead of a friendly screen.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.home => _page(const HomeScreen(), settings),
      Routes.settings => _page(const SettingsScreen(), settings),
      // The gameplay screen validates its own argument and shows a friendly
      // message when it receives something unexpected.
      Routes.gameplay => _page(
        GamePlayScreen(item: settings.arguments),
        settings,
      ),
      _ => _page(const HomeScreen(), settings),
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      _page(const HomeScreen(), settings);

  static MaterialPageRoute<dynamic> _page(
    Widget widget,
    RouteSettings settings,
  ) => MaterialPageRoute<dynamic>(
    builder: (_) => widget,
    settings: settings,
  );
}

