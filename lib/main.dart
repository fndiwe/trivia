import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/ui/screens/unsupported_platform.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/utils/routes.dart';
import 'package:trivia/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Isar has no browser backend; fail gracefully instead of crashing when the
  // app is opened on the web (the platform folder still exists).
  if (kIsWeb) {
    runApp(const UnsupportedPlatformApp(platform: 'the web'));
    return;
  }

  final documentsDirectory = await getApplicationDocumentsDirectory();
  await Repository.init(directory: documentsDirectory.path);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const TriviaApp(),
    ),
  );
}

/// Root of the application.
class TriviaApp extends StatefulWidget {
  const TriviaApp({super.key});

  @override
  State<TriviaApp> createState() => _TriviaAppState();
}

class _TriviaAppState extends State<TriviaApp> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().initSettings();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final theme = resolveTheme(
      mode: settings.theme,
      platformBrightness: platformBrightness,
    );
    final iconBrightness = overlayIconBrightness(theme);

    // Keep the system bars in step with the *resolved* theme, including when
    // ThemeMode.system is following the OS.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.colorScheme.surface,
        systemNavigationBarColor: theme.colorScheme.surface,
        statusBarIconBrightness: iconBrightness,
        systemNavigationBarIconBrightness: iconBrightness,
      ),
    );

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: settings.theme,
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
