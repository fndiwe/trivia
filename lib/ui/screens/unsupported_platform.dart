import 'package:flutter/material.dart';

/// Shown when the app is launched on a platform Isar cannot run on (web).
///
/// `getApplicationDocumentsDirectory()` throws on web and Isar 3 has no stable
/// browser backend, so instead of crashing on the first frame we explain the
/// situation.
class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key, required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.desktop_access_disabled_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  'TriviaHQ is not available on $platform',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The app stores its question bank locally with Isar, which is '
                  'not supported in the browser yet. Use the Android, iOS, '
                  'macOS, Windows or Linux build instead.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
