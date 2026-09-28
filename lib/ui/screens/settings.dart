import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/ui/widgets/app_drop_down.dart';
import 'package:trivia/utils/scoring.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final List<DropdownMenuState> _themes = [
    DropdownMenuState(label: 'Light', value: ThemeMode.light.name),
    DropdownMenuState(label: 'Dark', value: ThemeMode.dark.name),
    DropdownMenuState(label: 'System', value: ThemeMode.system.name),
  ];

  static final List<DropdownMenuState> _roundSizes = [
    for (final size in categoryRoundSizeOptions)
      DropdownMenuState(label: '$size questions', value: '$size'),
  ];

  static final List<DropdownMenuState> _timers = [
    for (final seconds in timerOptions)
      DropdownMenuState(
        label: seconds == 0 ? 'Off' : '$seconds seconds',
        value: '$seconds',
      ),
  ];

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

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears every level score, re-locks all levels except the '
            'first one and clears every category best score. It cannot be '
            'undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dialogTheme.colorScheme.errorContainer,
                foregroundColor: dialogTheme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
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
    ).showSnackBar(const SnackBar(content: Text('Progress reset.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _SectionTitle('Appearance'),
          TitledDropdown(
            theme: theme,
            title: 'Theme',
            list: _themes,
            value: _selected(
              _themes,
              settings.theme.name,
              fallback: _themes.last,
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
          const _SectionTitle('Gameplay'),
          TitledDropdown(
            theme: theme,
            title: 'Questions per round',
            list: _roundSizes,
            value: _selected(
              _roundSizes,
              '${settings.categoryRoundSize}',
              fallback: _roundSizes.first,
            ),
            onSelected: (value) {
              final size = int.tryParse(value ?? '');
              if (size != null) settingsProvider.setCategoryRoundSize(size);
            },
          ),
          TitledDropdown(
            theme: theme,
            title: 'Seconds per question',
            list: _timers,
            value: _selected(
              _timers,
              '${settings.secondsPerQuestion}',
              fallback: _timers.first,
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
            title: Text('Sound effects', style: theme.textTheme.titleMedium),
            subtitle: const Text('Play a sound for correct and wrong answers.'),
          ),
          SwitchListTile.adaptive(
            value: settings.hapticsEnabled,
            onChanged: settingsProvider.setHapticsEnabled,
            secondary: const Icon(Icons.vibration),
            title: Text('Vibration', style: theme.textTheme.titleMedium),
            subtitle: const Text('Light haptic feedback when you answer.'),
          ),
          const Divider(height: 1),
          const _SectionTitle('Data'),
          ListTile(
            leading: Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: Text(
              'Reset progress',
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            subtitle: const Text(
              'Clear level scores, unlocks and category best scores.',
            ),
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
