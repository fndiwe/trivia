import 'dart:math';

import 'package:isar/isar.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/repository/stats_repository.dart';
import 'package:trivia/utils/dates.dart';
import 'package:trivia/utils/quiz_selection.dart';

/// Reads quiz questions out of Isar.
///
/// Levels used to be served with `.limit(10).findAll()`, i.e. always the same
/// ten rows in id order, so replaying a level asked the exact same questions in
/// the exact same order. Questions are now drawn at random per round.
class QuizRepository {
  QuizRepository._();

  /// Builds the question list for [request], capped at [roundSize] questions.
  static Future<List<Trivia>> questionsFor(
    QuizRequest request, {
    required int roundSize,
    Random? random,
  }) {
    switch (request.mode) {
      case RoundMode.level:
        final level = request.level;
        if (level == null) return Future.value(const <Trivia>[]);
        return levelQuestions(level.id, roundSize, random: random);
      case RoundMode.category:
        final category = request.category;
        if (category == null) return Future.value(const <Trivia>[]);
        return categoryQuestions(
          category.categoryId,
          roundSize,
          random: random,
        );
      case RoundMode.daily:
        return dailyChallengeQuestions(roundSize, random: random);
      case RoundMode.practice:
        return practiceQuestions(roundSize, random: random);
    }
  }

  static Future<List<Trivia>> levelQuestions(
    int levelId,
    int count, {
    Random? random,
  }) async {
    final isar = Repository.isar;
    final pool = await isar.trivias.where().levelEqualTo(levelId).findAll();
    return pickRandom(pool, count, random: random);
  }

  static Future<List<Trivia>> categoryQuestions(
    String categoryId,
    int count, {
    Random? random,
  }) async {
    final isar = Repository.isar;
    final pool =
        await isar.trivias.where().categoryEqualTo(categoryId).findAll();
    return pickRandom(pool, count, random: random);
  }

  /// The daily challenge: the same questions on every device, for one day.
  ///
  /// Questions are read in a stable order (sorted by question text rather than
  /// by auto-increment id, which depends on the randomised import) and sampled
  /// with a [Random] seeded from the calendar date.
  static Future<List<Trivia>> dailyChallengeQuestions(
    int count, {
    DateTime? today,
    Random? random,
  }) async {
    final isar = Repository.isar;
    final day = localDayOf(today ?? DateTime.now());
    final pool = await isar.trivias.where().sortByQuestion().findAll();
    return pickRandom(pool, count, random: random ?? Random(dailySeedFor(day)));
  }

  /// Questions the player has answered wrongly before, hardest first.
  static Future<List<Trivia>> practiceQuestions(
    int count, {
    Random? random,
  }) async {
    final isar = Repository.isar;
    final queue = await StatsRepository.practiceQueue(limit: count);
    if (queue.isEmpty) return const <Trivia>[];

    final questions = <Trivia>[];
    for (final stat in queue) {
      final trivia =
          await isar.trivias.where().questionEqualTo(stat.question).findFirst();
      if (trivia != null) questions.add(trivia);
    }
    return pickRandom(questions, count, random: random);
  }
}
