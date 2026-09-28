import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/utils/extract_trivia_data.dart';

/// First-launch bootstrap: imports the bundled question bank when needed, then
/// loads the level and category grids before handing over to the home tabs.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Minimum time the branding stays on screen so a warm start does not flash.
  static const Duration _minimumDisplay = Duration(milliseconds: 700);

  bool _started = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies can fire more than once; only bootstrap once.
    if (_started) return;
    _started = true;
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    try {
      final settingsProvider = context.read<SettingsProvider>();
      // Make sure the stored settings (and therefore the imported question-bank
      // version) are loaded before deciding whether to import.
      await settingsProvider.initSettings();
      if (!mounted) return;

      if (settingsProvider.settings.questionBankVersion !=
          currentQuestionBankVersion) {
        await ProgressRepository.clearQuestions();
        await extractDataToDatabase();
        await settingsProvider.setQuestionBankVersion(
          currentQuestionBankVersion,
        );
      }

      if (!mounted) return;
      await context.read<HomeProvider>().loadAll();

      final elapsed = DateTime.now().difference(started);
      if (elapsed < _minimumDisplay) {
        await Future<void>.delayed(_minimumDisplay - elapsed);
      }
      if (!mounted) return;
      context.read<HomeProvider>().finishSplash();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not prepare the quiz data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TriviaHQ',
                style: theme.textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              if (_error == null)
                const SizedBox(width: 160, child: LinearProgressIndicator())
              else ...[
                Icon(
                  Icons.error_outline,
                  size: 42,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    setState(() => _error = null);
                    unawaited(_bootstrap());
                  },
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
