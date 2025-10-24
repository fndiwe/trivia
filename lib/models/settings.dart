import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id id = 1;
  @enumerated
  ThemeMode theme = ThemeMode.system;
  bool soundEnabled = true;
}