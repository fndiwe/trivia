import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/ui/screens/gameplay.dart';
import 'package:trivia/ui/screens/home.dart';
import 'package:trivia/ui/screens/settings.dart';
import 'package:trivia/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Isar.open([
    TriviaSchema,
    LevelSchema,
    CategorySchema,
    SettingsSchema,
  ], directory: dir.path);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.initSettings();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final systemTheme = MediaQuery.platformBrightnessOf(context);
    final lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.light(
        primary: const Color.fromARGB(255, 2, 78, 139),
        primaryContainer: Colors.black.withAlpha(150),
        secondary: Colors.black12,
      ),
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.dark(
        primary: const Color.fromARGB(255, 0, 100, 182),
        primaryContainer: Colors.white.withAlpha(100),
        onPrimary: Colors.white,
        secondary: Colors.white12,
      ),
    );
    final theme =
        settingsProvider.settings.theme == ThemeMode.dark ||
                settingsProvider.settings.theme == ThemeMode.system &&
                    systemTheme == Brightness.dark
            ? darkTheme
            : lightTheme;

    final Brightness brightness =
        settingsProvider.settings.theme == ThemeMode.dark ||
                settingsProvider.settings.theme == ThemeMode.system &&
                    systemTheme == Brightness.dark
            ? Brightness.light
            : Brightness.dark;

    // Configure system UI for edge-to-edge display
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.colorScheme.surface,
        systemNavigationBarColor: theme.colorScheme.surface,
        statusBarIconBrightness: brightness,
        systemNavigationBarIconBrightness: brightness,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settingsProvider.settings.theme,
      initialRoute: Routes.home,
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder> {
        Routes.home: (_) => const HomeScreen(),
        Routes.settings: (_) => const SettingsScreen(),
        Routes.gameplay: (_) => GamePlayScreen(item: settings.arguments,),
        };
        WidgetBuilder? builder = routes[settings.name];
        return MaterialPageRoute(builder:(context) => builder!(context),);
      },
    );
  }
}
