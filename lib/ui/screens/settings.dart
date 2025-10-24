import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/ui/widgets/app_drop_down.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _themes = [
    DropdownMenuState(label: "Light", value: ThemeMode.light.name),
    DropdownMenuState(label: "Dark", value: ThemeMode.dark.name),
    DropdownMenuState(label: "System", value: ThemeMode.system.name),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TitledDropdown(
              theme: theme,
              title: "Theme",
              list: _themes,
              onSelected:
                  (value) => settingsProvider.changeSettings(
                    settingsProvider.settings
                      ..theme = ThemeMode.values.firstWhere(
                        (item) => item.name == value,
                      ),
                  ),
              value: _themes.firstWhere(
                (item) => item.value == settingsProvider.settings.theme.name,
              ),
            ),
            SwitchListTile.adaptive(
              value: settingsProvider.settings.soundEnabled,
              onChanged:
                  (value) => settingsProvider.changeSettings(
                    settingsProvider.settings..soundEnabled = value,
                  ),
              title: Text("Sound", style: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
