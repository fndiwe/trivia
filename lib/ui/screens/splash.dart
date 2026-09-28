import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/utils/extract_trivia_data.dart';
import 'package:trivia/l10n/l10n.dart';

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

  /// 0..1 while the bundled question bank is being imported, `null` otherwise.
  double? _importProgress;
  int _importDone = 0;
  int _importTotal = 0;

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
        if (mounted) {
          setState(() {
            _importProgress = 0;
            _importDone = 0;
            _importTotal = 0;
          });
        }
        await importQuestionBank(
          onProgress: (done, total) {
            if (!mounted) return;
            setState(() {
              _importDone = done;
              _importTotal = total;
              _importProgress = total == 0 ? 1 : done / total;
            });
          },
        );
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
      setState(() => _error = context.l10n.couldNotPrepare);
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
                context.l10n.appTitle,
                style: theme.textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              if (_error == null) ...[
                if (_importProgress != null) ...[
                  Text(
                    context.l10n.preparingBank,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_importDone / $_importTotal',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(value: _importProgress),
                ),
              ] else ...[
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
                  child: Text(context.l10n.tryAgain),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
