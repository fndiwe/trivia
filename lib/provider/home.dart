import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/repository/stats_repository.dart';

/// Backing store for the home screen: the level grid on the first tab and the
/// category grid on the second.
class HomeProvider extends ChangeNotifier {
  bool showSplash = true;
  List<Level> levels = <Level>[];
  List<Category> categories = <Category>[];

  /// Questions waiting in the "practise your mistakes" queue.
  int practiceCount = 0;

  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadLevels() async {
    final isar = Repository.isar;
    levels = await isar.levels.where().findAll();
    _safeNotify();
  }

  Future<void> loadCategories() async {
    final isar = Repository.isar;
    categories = await isar.categorys.where().findAll();
    _safeNotify();
  }

  /// Loads both tabs in parallel.
  /// Loads the practice-queue size shown on the home screen.
  Future<void> loadPracticeCount() async {
    practiceCount = (await StatsRepository.practiceQueue()).length;
    _safeNotify();
  }

  /// Loads the level list, the category list and the practice-queue size.
  Future<void> loadAll() =>
      Future.wait([loadLevels(), loadCategories(), loadPracticeCount()]);

  /// Leaves the splash screen and shows the home tabs.
  void finishSplash() {
    showSplash = false;
    _safeNotify();
  }

  void changeShowSplash({bool show = false}) {
    showSplash = show;
    _safeNotify();
  }

  // Update a level's score in-memory and notify listeners (avoids re-querying Isar)
  void updateLevelScore(int levelId, int? score) {
    final idx = levels.indexWhere((l) => l.id == levelId);
    if (idx >= 0) {
      levels[idx].score = score;
      _safeNotify();
    }
  }

  // Unlock the next level (set its score to 0) in-memory and notify listeners
  void unlockNextLevel(int currentLevelId) {
    final nextId = currentLevelId + 1;
    final idx = levels.indexWhere((l) => l.id == nextId);
    if (idx >= 0 && levels[idx].score == null) {
      levels[idx].score = 0;
      _safeNotify();
    }
  }

  // Update a category's highest score in-memory and notify listeners
  void updateCategoryHighest(String categoryId, int highest) {
    final idx = categories.indexWhere((c) => c.categoryId == categoryId);
    if (idx >= 0) {
      categories[idx].highestScore = highest;
      _safeNotify();
    }
  }
}
