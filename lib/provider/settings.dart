import 'package:flutter/material.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/repository/repository.dart';

/// Loads and persists user preferences.
class SettingsProvider extends ChangeNotifier {
  Settings _settings = Settings();

  /// True once the stored row has been read (or created) on first launch.
  bool _isLoaded = false;

  Future<void>? _loading;

  bool _disposed = false;

  Settings get settings => _settings;

  bool get isLoaded => _isLoaded;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initSettings() => _loading ??= _loadSettings();

  Future<void> _loadSettings() async {
    final isar = Repository.isar;
    final stored = await isar.settings.get(_settings.id);
    if (stored != null) {
      _settings = stored;
    } else {
      await isar.writeTxn(() => isar.settings.put(_settings));
    }
    _isLoaded = true;
    _safeNotify();
  }

  /// Re-reads the stored row.
  ///
  /// Needed after a repository transaction that touches settings directly (the
  /// round history updates the streak and the daily-challenge date), so the UI
  /// does not show stale values.
  Future<void> refresh() async {
    final isar = Repository.isar;
    final stored = await isar.settings.get(_settings.id);
    if (stored != null) _settings = stored;
    _isLoaded = true;
    _safeNotify();
  }

  /// Applies [change] to the current settings, updates the UI immediately and
  /// persists in the background.
  ///
  /// Previously every caller had to remember to mutate the shared `Settings`
  /// instance and hand it back to `changeSettings`, which made it very easy to
  /// forget the write.
  Future<void> update(Settings Function(Settings current) change) async {
    final updated = change(_settings);
    _settings = updated;
    _safeNotify();
    final isar = Repository.isar;
    await isar.writeTxn(() async {
      await isar.settings.put(updated);
    });
  }

  Future<void> setTheme(ThemeMode theme) =>
      update((settings) => settings.copyWith(theme: theme));

  Future<void> setSoundEnabled(bool enabled) =>
      update((settings) => settings.copyWith(soundEnabled: enabled));

  Future<void> setHapticsEnabled(bool enabled) =>
      update((settings) => settings.copyWith(hapticsEnabled: enabled));

  Future<void> setCategoryRoundSize(int size) =>
      update((settings) => settings.copyWith(categoryRoundSize: size));

  Future<void> setSecondsPerQuestion(int seconds) =>
      update((settings) => settings.copyWith(secondsPerQuestion: seconds));

  Future<void> setQuestionBankVersion(int version) =>
      update((settings) => settings.copyWith(questionBankVersion: version));

  /// Kept for backwards compatibility with the old call sites.
  Future<void> changeSettings(Settings newSettings) =>
      update((_) => newSettings);
}
