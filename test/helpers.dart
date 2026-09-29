import 'package:flutter/material.dart';
import 'package:trivia/l10n/l10n.dart';

/// Wraps [child] in a `MaterialApp` wired with the app's localizations, like
/// the real app. Any widget that resolves `context.l10n` needs this.
Widget localizedApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

/// A localized wrapper for widgets that provide their own [Scaffold].
Widget localizedRoot(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
