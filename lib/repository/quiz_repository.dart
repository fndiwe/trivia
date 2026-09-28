import 'dart:math';

import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/utils/quiz_selection.dart';

/// Reads quiz questions out of Isar.
///
/// Levels used to be served with `.limit(10).findAll()`, i.e. always the same
/// ten rows in id order, so replaying a level asked the exact same questions in
/// the exact same order. Questions are now drawn at random per round.
class QuizRepository {
  QuizRepository._();

  static Future<List<Trivia>> levelQuestions(
    int levelId,
    int count, {
    Random? random,
  }) async {
    final isar = Repository.isar;
    final pool = await isar.trivias.filter().levelEqualTo(levelId).findAll();
    return pickRandom(pool, count, random: random);
  }

  static Future<List<Trivia>> categoryQuestions(
    String categoryId,
    int count, {
    Random? random,
  }) async {
    final isar = Repository.isar;
    final pool =
        await isar.trivias.filter().categoryEqualTo(categoryId).findAll();
    return pickRandom(pool, count, random: random);
  }

  /// Convenience entry point for the game screen, which receives either a
  /// [Level] or a [Category] as its route argument.
  static Future<List<Trivia>> questionsFor(
    Object item, {
    required int count,
    Random? random,
  }) {
    if (item is Level) return levelQuestions(item.id, count, random: random);
    if (item is Category) {
      return categoryQuestions(item.categoryId, count, random: random);
    }
    throw ArgumentError.value(item, 'item', 'Expected a Level or a Category');
  }
}
