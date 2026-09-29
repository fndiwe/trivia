import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/ui/widgets/app_drop_down.dart';
import 'package:trivia/utils/scoring.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Picks the option matching [value], falling back to [fallback] when the
  /// stored value is not offered any more (e.g. after an app update).
  static DropdownMenuState _selected(
    List<DropdownMenuState> options,
    String value, {
    required DropdownMenuState fallback,
  }) => options.firstWhere(
    (option) => option.value == value,
    orElse: () => fallback,
  );

  static List<DropdownMenuState> _themeOptions(BuildContext context) => [
    DropdownMenuState(
      label: context.l10n.themeLight,
      value: ThemeMode.light.name,
    ),
    DropdownMenuState(
      label: context.l10n.themeDark,
      value: ThemeMode.dark.name,
    ),
    DropdownMenuState(
      label: context.l10n.themeSystem,
      value: ThemeMode.system.name,
    ),
  ];

  static List<DropdownMenuState> _roundSizeOptions(BuildContext context) => [
    for (final size in categoryRoundSizeOptions)
      DropdownMenuState(
        label: context.l10n.questionsPerRoundValue(size),
        value: '$size',
      ),
  ];

  static List<DropdownMenuState> _timerOptions(BuildContext context) => [
    for (final seconds in timerOptions)
      DropdownMenuState(
        label:
            seconds == 0
                ? context.l10n.timerOff
                : context.l10n.timerSeconds(seconds),
        value: '$seconds',
      ),
  ];

  Future<void> _rebalance(BuildContext context) async {
    final summary = await ProgressRepository.rebalanceCampaign();
    if (!context.mounted) return;
    await context.read<HomeProvider>().loadAll();
    if (!context.mounted) return;
    final message =
        summary.anythingMoved
            ? context.l10n.rebalanceDone(summary.movedQuestions)
            : context.l10n.rebalanceNothing;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text(context.l10n.resetProgressQuestion),
          content: Text(context.l10n.resetProgressBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dialogTheme.colorScheme.errorContainer,
                foregroundColor: dialogTheme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.reset),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await ProgressRepository.resetProgress();
    if (!context.mounted) return;
    // Refresh the grids so the reset is visible straight away.
    await context.read<HomeProvider>().loadAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.progressReset)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    final themes = _themeOptions(context);
    final roundSizes = _roundSizeOptions(context);
    final timers = _timerOptions(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.settingsTitle,
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _SectionTitle(context.l10n.sectionAppearance),
          TitledDropdown(
            theme: theme,
            title: context.l10n.themeTitle,
            list: themes,
            value: _selected(
              themes,
              settings.theme.name,
              fallback: themes.last,
            ),
            onSelected: (value) {
              if (value == null) return;
              settingsProvider.setTheme(
                ThemeMode.values.firstWhere(
                  (mode) => mode.name == value,
                  orElse: () => ThemeMode.system,
                ),
              );
            },
          ),
          const Divider(height: 1),
          _SectionTitle(context.l10n.sectionGameplay),
          TitledDropdown(
            theme: theme,
            title: context.l10n.questionsPerRound,
            list: roundSizes,
            value: _selected(
              roundSizes,
              '${settings.categoryRoundSize}',
              fallback: roundSizes.first,
            ),
            onSelected: (value) {
              final size = int.tryParse(value ?? '');
              if (size != null) settingsProvider.setCategoryRoundSize(size);
            },
          ),
          TitledDropdown(
            theme: theme,
            title: context.l10n.secondsPerQuestion,
            list: timers,
            value: _selected(
              timers,
              '${settings.secondsPerQuestion}',
              fallback: timers.first,
            ),
            onSelected: (value) {
              final seconds = int.tryParse(value ?? '');
              if (seconds != null) {
                settingsProvider.setSecondsPerQuestion(seconds);
              }
            },
          ),
          SwitchListTile.adaptive(
            value: settings.soundEnabled,
            onChanged: settingsProvider.setSoundEnabled,
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(
              context.l10n.soundEffects,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(context.l10n.soundEffectsSubtitle),
          ),
          SwitchListTile.adaptive(
            value: settings.hapticsEnabled,
            onChanged: settingsProvider.setHapticsEnabled,
            secondary: const Icon(Icons.vibration),
            title: Text(
              context.l10n.vibration,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(context.l10n.vibrationSubtitle),
          ),
          const Divider(height: 1),
          _SectionTitle(context.l10n.sectionData),
          ListTile(
            leading: Icon(
              Icons.auto_graph_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              context.l10n.rebalanceTitle,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(context.l10n.rebalanceSubtitle),
            onTap: () => _rebalance(context),
          ),
          ListTile(
            leading: Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: Text(
              context.l10n.resetProgressTitle,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            subtitle: Text(context.l10n.resetProgressSubtitle),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
