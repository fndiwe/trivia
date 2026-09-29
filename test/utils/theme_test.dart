import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveTheme', () {
    test('honours an explicit light preference', () {
      final theme = resolveTheme(
        mode: ThemeMode.light,
        platformBrightness: Brightness.dark,
      );
      expect(theme.brightness, Brightness.light);
    });

    test('honours an explicit dark preference', () {
      final theme = resolveTheme(
        mode: ThemeMode.dark,
        platformBrightness: Brightness.light,
      );
      expect(theme.brightness, Brightness.dark);
    });

    test('follows the platform when set to system', () {
      expect(
        resolveTheme(
          mode: ThemeMode.system,
          platformBrightness: Brightness.dark,
        ).brightness,
        Brightness.dark,
      );
      expect(
        resolveTheme(
          mode: ThemeMode.system,
          platformBrightness: Brightness.light,
        ).brightness,
        Brightness.light,
      );
    });
  });

  group('themes', () {
    test('use Material 3 and the bundled Nunito font', () {
      expect(buildLightTheme().useMaterial3, isTrue);
      expect(buildLightTheme().textTheme.bodyMedium?.fontFamily, 'Nunito');
      expect(buildDarkTheme().useMaterial3, isTrue);
    });

    test('give the tabs readable on-container colours', () {
      // Regression guard: the light scheme used to hard-code a *dark*
      // primaryContainer while keeping the default dark onPrimaryContainer,
      // which made the tab labels nearly invisible.
      final scheme = buildLightTheme().colorScheme;
      expect(scheme.onPrimaryContainer, isNot(equals(scheme.primaryContainer)));
    });
  });

  group('overlayIconBrightness', () {
    test(
      'uses light icons on a dark surface and dark icons on a light one',
      () {
        expect(overlayIconBrightness(buildDarkTheme()), Brightness.light);
        expect(overlayIconBrightness(buildLightTheme()), Brightness.dark);
      },
    );
  });
}
