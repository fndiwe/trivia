import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/repository/repository.dart';

class HomeProvider extends ChangeNotifier {
  bool showSplash = true;
  List<Level> levels = [];
  List<Category> categories = [];

  void loadLevels() async {
    final isar = Repository.isar;
    levels = await isar.levels.where().findAll();
    notifyListeners();
  }

  void loadCategories() async {
    final isar = Repository.isar;
    categories = await isar.categorys.where().findAll();
    notifyListeners();
  }

  void changeShowSplash({bool show = false}) {
    showSplash = show;
    notifyListeners();
  }

  // Update a level's score in-memory and notify listeners (avoids re-querying Isar)
  void updateLevelScore(int levelId, int? score) {
    final idx = levels.indexWhere((l) => l.id == levelId);
    if (idx >= 0) {
      levels[idx].score = score;
      notifyListeners();
    }
  }

  // Unlock the next level (set its score to 0) in-memory and notify listeners
  void unlockNextLevel(int currentLevelId) {
    final nextId = currentLevelId + 1;
    final idx = levels.indexWhere((l) => l.id == nextId);
    if (idx >= 0 && levels[idx].score == null) {
      levels[idx].score = 0;
      notifyListeners();
    }
  }

  // Update a category's highest score in-memory and notify listeners
  void updateCategoryHighest(String categoryId, int highest) {
    final idx = categories.indexWhere((c) => c.categoryId == categoryId);
    if (idx >= 0) {
      categories[idx].highestScore = highest;
      notifyListeners();
    }
  }
}
