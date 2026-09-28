import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';

/// Player progress: level scores (which double as "unlocked" flags) and the
/// best score per category.
class ProgressRepository {
  ProgressRepository._();

  /// Puts the player back to a fresh install: level 1 unlocked with a score of
  /// zero, every other level locked, every category best score cleared.
  static Future<void> resetProgress() async {
    final isar = Repository.isar;
    await isar.writeTxn(() async {
      final levels = await isar.levels.where().findAll();
      for (final level in levels) {
        level.score = level.id == 1 ? 0 : null;
        await isar.levels.put(level);
      }

      final categories = await isar.categorys.where().findAll();
      for (final category in categories) {
        category.highestScore = 0;
        await isar.categorys.put(category);
      }
    });
  }

  /// Deletes all derived data so the next launch re-imports `assets/trivia.json`
  /// (useful after the bundled question set changes).
  static Future<void> clearQuestions() async {
    final isar = Repository.isar;
    await isar.writeTxn(() async {
      await isar.trivias.clear();
      await isar.levels.clear();
      await isar.categorys.clear();
    });
  }
}
