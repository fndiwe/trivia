import 'dart:async';

import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/rebalance_summary.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/models/round_summary.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/utils/difficulty.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/repository/stats_repository.dart';
import 'package:trivia/utils/dates.dart';
import 'package:trivia/utils/scoring.dart';

/// Player progress: level scores (which double as "unlocked" flags), category
/// best scores, round history and the daily streak.
class ProgressRepository {
  ProgressRepository._();

  /// Persists a finished round and returns everything that changed.
  ///
  /// All of the "what does finishing a round mean" logic used to live inside the
  /// results widget, spread over nested `if`s and swallowed exceptions; it is
  /// now one transaction that either fully applies or fails loudly.
  static Future<RoundSummary> saveRound({
    required RoundMode mode,
    required int score,
    required int total,
    int? levelId,
    String? categoryId,
    DateTime? playedAt,
  }) async {
    final isar = Repository.isar;
    final moment = playedAt ?? DateTime.now();

    var newCategoryBest = false;
    int? unlockedLevelId;
    var streak = 1;
    var streakIncreased = false;
    var longestStreak = 0;

    await isar.writeTxn(() async {
      await isar.roundResults.put(
        RoundResult(
          playedAt: moment,
          mode: mode,
          score: score,
          total: total,
          levelId: levelId,
          categoryId: categoryId,
        ),
      );

      if (levelId != null) {
        final level = await isar.levels.get(levelId);
        if (level != null) {
          level.score = score;
          await isar.levels.put(level);

          // Unlock the next level if it is still locked (score == null).
          final next = await isar.levels.get(levelId + 1);
          if (next != null && next.score == null) {
            next.score = 0;
            await isar.levels.put(next);
            unlockedLevelId = next.id;
          }
        }
      }

      if (categoryId != null) {
        final category =
            await isar.categorys
                .where()
                .categoryIdEqualTo(categoryId)
                .findFirst();
        if (category != null && category.recordScore(score)) {
          await isar.categorys.put(category);
          newCategoryBest = true;
        }
      }

      // Streak bookkeeping lives here so every entry point behaves the same.
      final stored = await isar.settings.get(1) ?? Settings();
      streak = streakAfterRound(
        today: moment,
        lastPlayedOn: stored.lastPlayedOn,
        currentStreak: stored.currentStreak,
      );
      streakIncreased = streak > stored.currentStreak;
      longestStreak =
          streak > stored.longestStreak ? streak : stored.longestStreak;

      await isar.settings.put(
        stored.copyWith(
          lastPlayedOn: moment,
          currentStreak: streak,
          longestStreak: longestStreak,
          dailyChallengeCompletedOn:
              mode == RoundMode.daily
                  ? moment
                  : stored.dailyChallengeCompletedOn,
        ),
      );
    });

    final practiceQueue = await StatsRepository.practiceQueue();

    // Re-rank the campaign occasionally once the player has enough answers for
    // the estimate to be meaningful. Fire-and-forget: the result screen is
    // already loaded, and the home grid reflects the rebalance on its next
    // load because unlocks are preserved by rank.
    unawaited(maybeRebalance());

    return RoundSummary(
      score: score,
      total: total,
      stars: starsFor(score, total),
      newCategoryBest: newCategoryBest,
      unlockedLevelId: unlockedLevelId,
      streak: streak,
      streakIncreased: streakIncreased,
      longestStreak: longestStreak,
      practiceQuestionCount: practiceQueue.length,
    );
  }

  /// Re-estimates question difficulty from the player's statistics and
  /// re-partitions the campaign so easier questions come first.
  ///
  /// Questions the player has answered are rescored with the empirical
  /// posterior; everything else keeps its intrinsic estimate. Only rows whose
  /// level actually changes are rewritten, which keeps the write small on a
  /// mostly-stable ladder. Unlock states and level scores are preserved by
  /// *rank* (the player still has the first K levels unlocked); the content at
  /// each position now reflects the current difficulty estimate.
  static Future<RebalanceSummary> rebalanceCampaign({int alpha = 8}) async {
    final isar = Repository.isar;
    final questions = await isar.trivias.where().sortByQuestion().findAll();
    if (questions.isEmpty) {
      return const RebalanceSummary(
        levelCount: 0,
        rescoredQuestions: 0,
        movedQuestions: 0,
      );
    }

    final stats = await isar.questionStats.where().findAll();
    final statsByQuestion = <String, QuestionStat>{
      for (final stat in stats) stat.question: stat,
    };

    final rescored = <Trivia>[];
    var rescoredCount = 0;
    for (final question in questions) {
      final stat = statsByQuestion[question.question];
      if (stat == null || stat.timesShown == 0) {
        rescored.add(question);
        continue;
      }
      rescored.add(
        question.withDifficulty(
          posteriorDifficulty(
            correct: stat.timesCorrect,
            shown: stat.timesShown,
            intrinsic: question.difficulty,
            alpha: alpha,
          ),
        ),
      );
      rescoredCount++;
    }

    final ranked = List<Trivia>.of(rescored)
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));

    final storedById = <int, Trivia>{
      for (final question in questions) question.id: question,
    };

    var moved = 0;
    await isar.writeTxn(() async {
      for (var index = 0; index < ranked.length; index++) {
        final target = ranked[index];
        final stored = storedById[target.id]!;
        final targetLevel = (index ~/ questionsPerLevel) + 1;
        if (stored.level != targetLevel ||
            stored.difficulty != target.difficulty) {
          await isar.trivias.put(
            stored.withLevel(targetLevel).withDifficulty(target.difficulty),
          );
          moved++;
        }
      }
    });

    return RebalanceSummary(
      levelCount: (questions.length / questionsPerLevel).ceil(),
      rescoredQuestions: rescoredCount,
      movedQuestions: moved,
    );
  }

  /// Runs a rebalance only when it is due: at most once per [maxAge] period
  /// and only once the player has answered at least [minAnswers] questions.
  /// Returns `true` when a rebalance actually ran.
  static Future<bool> maybeRebalance({
    int minAnswers = 50,
    Duration maxAge = const Duration(days: 1),
    DateTime? now,
  }) async {
    final isar = Repository.isar;
    final moment = now ?? DateTime.now();

    final settings = await isar.settings.get(1);
    final last = settings?.lastRebalancedOn;
    if (last != null && moment.difference(last) < maxAge) return false;

    final stats = await StatsRepository.load();
    if (stats.answersGiven < minAnswers) return false;

    await rebalanceCampaign();

    final stored = await isar.settings.get(1);
    if (stored != null) {
      await isar.writeTxn(() async {
        await isar.settings.put(stored..lastRebalancedOn = moment);
      });
    }
    return true;
  }

  /// Puts the player back to a fresh install: level 1 unlocked with a score of
  /// zero, every other level locked, every category best score cleared, and all
  /// history (rounds, per-question statistics, streaks) removed.
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

      await isar.roundResults.clear();
      await isar.questionStats.clear();

      final stored = await isar.settings.get(1);
      if (stored != null) {
        await isar.settings.put(
          stored
            ..currentStreak = 0
            ..longestStreak = 0
            ..lastPlayedOn = null
            ..dailyChallengeCompletedOn = null,
        );
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
