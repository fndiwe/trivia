import 'package:flutter/material.dart';

/// The brand palette, kept in one place so screens stop re-declaring colours.
class AppColors {
  const AppColors._();

  static const Color seedLight = Color.fromARGB(255, 2, 78, 139);
  static const Color seedDark = Color.fromARGB(255, 0, 100, 182);

  /// Green used for a correct answer in the light theme.
  static const Color correct = Color(0xFF2E7D32);

  /// Lighter green for the dark theme, where [correct] would sit too close to
  /// the dark surface to read comfortably.
  static const Color correctDark = Color(0xFF66BB6A);

  /// The correct-answer colour for [theme], with enough contrast on its own
  /// surface in either brightness.
  static Color correctFor(ThemeData theme) =>
      theme.brightness == Brightness.dark ? correctDark : correct;
}

/// Builds the light theme. Material 3 + the bundled Nunito font.
ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.seedLight,
    brightness: Brightness.light,
  ),
);

/// Builds the dark theme.
ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.seedDark,
    brightness: Brightness.dark,
  ),
);

/// Resolves the [ThemeMode] the app should be using right now.
///
/// Pure function (no `BuildContext`) so it can be unit tested and reused by the
/// system-UI overlay configuration.
ThemeData resolveTheme({
  required ThemeMode mode,
  required Brightness platformBrightness,
}) {
  switch (mode) {
    case ThemeMode.light:
      return buildLightTheme();
    case ThemeMode.dark:
      return buildDarkTheme();
    case ThemeMode.system:
      return platformBrightness == Brightness.dark
          ? buildDarkTheme()
          : buildLightTheme();
  }
}

/// Icon brightness for the status/navigation bars that contrasts with the
/// surface of [theme].
Brightness overlayIconBrightness(ThemeData theme) =>
    theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark;
