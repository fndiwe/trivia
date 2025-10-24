import 'package:flutter/material.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/repository/repository.dart';

class SettingsProvider extends ChangeNotifier{
  Settings settings = Settings();

  void initSettings() async {
    final isar = Repository.isar;
    final isarSettings = await isar.settings.get(settings.id);
    if (isarSettings != null) {
      settings = isarSettings;    
    } else {
      await isar.writeTxn(() async {
        isar.settings.put(settings);
      });
    }
    notifyListeners();
  }

  void changeSettings(Settings newSettings) async {
    final isar = Repository.isar;
    settings = newSettings;
    await isar.writeTxn(() async {
      isar.settings.put(newSettings);
    });
    notifyListeners();
  }
}