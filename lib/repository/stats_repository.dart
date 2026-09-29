import 'package:isar/isar.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/repository/repository.dart';

/// Accuracy for a single category, used by the statistics screen.
class CategoryStats {
  const CategoryStats({
    required this.categoryId,
    required this.answered,
    required this.correct,
  });

  final String categoryId;
  final int answered;
  final int correct;

  double get accuracy => answered == 0 ? 0 : correct / answered;
}

/// Totals shown on the statistics screen.
class PlayerStats {
  const PlayerStats({
    required this.roundsPlayed,
    required this.bestRound,
    required this.answersGiven,
    required this.correctAnswers,
    required this.questionsSeen,
    required this.masteredQuestions,
    required this.questionsToPractise,
  });

  const PlayerStats.empty()
    : roundsPlayed = 0,
      bestRound = 0,
      answersGiven = 0,
      correctAnswers = 0,
      questionsSeen = 0,
      masteredQuestions = 0,
      questionsToPractise = 0;

  final int roundsPlayed;

  /// Highest score of any finished round.
  final int bestRound;

  final int answersGiven;
  final int correctAnswers;

  /// Distinct questions that have been asked at least once.
  final int questionsSeen;

  /// Distinct questions never answered wrongly.
  final int masteredQuestions;

  /// Distinct questions with at least one wrong answer.
  final int questionsToPractise;

  /// Ratio of correct answers across every round, `0` when nothing was played.
  double get accuracy => answersGiven == 0 ? 0 : correctAnswers / answersGiven;
}

/// Per-question performance: the raw material for the practice mode and the
/// statistics screen.
class StatsRepository {
  StatsRepository._();

  /// Records one answer against [question].
  ///
  /// Called from the game screen for every question that is resolved, whether
  /// the player answered it or the countdown ran out.
  static Future<void> recordAnswer({
    required String question,
    required bool correct,
    String category = '',
    DateTime? at,
  }) async {
    final isar = Repository.isar;
    final moment = at ?? DateTime.now();
    final existing =
        await isar.questionStats.where().questionEqualTo(question).findFirst();

    await isar.writeTxn(() async {
      if (existing == null) {
        final stat = QuestionStat(question: question, category: category)
          ..record(correct: correct, at: moment);
        await isar.questionStats.put(stat);
      } else {
        // Backfill the category on rows written before it was stored.
        if (existing.category.isEmpty && category.isNotEmpty) {
          existing.category = category;
        }
        existing.record(correct: correct, at: moment);
        await isar.questionStats.put(existing);
      }
    });
  }

  /// Per-category breakdown for the statistics screen, worst accuracy first.
  static Future<List<CategoryStats>> byCategory() async {
    final isar = Repository.isar;
    final stats = await isar.questionStats.where().findAll();
    final totals = <String, List<int>>{};
    for (final stat in stats) {
      if (stat.category.isEmpty || stat.timesShown == 0) continue;
      final entry = totals.putIfAbsent(stat.category, () => [0, 0]);
      entry[0] += stat.timesShown;
      entry[1] += stat.timesCorrect;
    }
    final list =
        totals.entries
            .map(
              (entry) => CategoryStats(
                categoryId: entry.key,
                answered: entry.value[0],
                correct: entry.value[1],
              ),
            )
            .toList()
          ..sort((a, b) {
            final byAccuracy = a.accuracy.compareTo(b.accuracy);
            if (byAccuracy != 0) return byAccuracy;
            return b.answered.compareTo(a.answered);
          });
    return list;
  }

  /// Questions with the lowest accuracy, for the "hardest questions" section.
  static Future<List<QuestionStat>> hardestQuestions({
    int limit = 10,
    String? categoryId,
    int minTimesShown = 2,
  }) async {
    final isar = Repository.isar;
    final stats = await isar.questionStats.where().findAll();
    final filtered =
        stats
            .where(
              (stat) =>
                  stat.timesShown >= minTimesShown &&
                  (categoryId == null || stat.category == categoryId),
            )
            .toList()
          ..sort((a, b) {
            final byAccuracy = a.accuracy.compareTo(b.accuracy);
            if (byAccuracy != 0) return byAccuracy;
            return b.timesShown.compareTo(a.timesShown);
          });
    return filtered.take(limit).toList();
  }

  /// Questions that have been answered wrongly at least once, hardest first.
  static Future<List<QuestionStat>> practiceQueue({int? limit}) async {
    final isar = Repository.isar;
    final stats = await isar.questionStats.where().findAll();
    final queue =
        stats.where((stat) => stat.needsPractice).toList()..sort((a, b) {
          final byAccuracy = a.accuracy.compareTo(b.accuracy);
          if (byAccuracy != 0) return byAccuracy;
          final aDate = a.lastAnsweredAt;
          final bDate = b.lastAnsweredAt;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });
    if (limit == null) return queue;
    return queue.take(limit).toList();
  }

  /// Aggregated numbers for the statistics screen.
  static Future<PlayerStats> load() async {
    final isar = Repository.isar;
    final rounds = await isar.roundResults.where().findAll();
    final stats = await isar.questionStats.where().findAll();

    if (rounds.isEmpty && stats.isEmpty) return const PlayerStats.empty();

    var answersGiven = 0;
    var correctAnswers = 0;
    var mastered = 0;
    var toPractise = 0;
    for (final stat in stats) {
      answersGiven += stat.timesShown;
      correctAnswers += stat.timesCorrect;
      if (stat.isMastered) mastered++;
      if (stat.needsPractice) toPractise++;
    }

    final bestRound =
        rounds.isEmpty
            ? 0
            : rounds
                .map((round) => round.score)
                .reduce((a, b) => a > b ? a : b);

    return PlayerStats(
      roundsPlayed: rounds.length,
      bestRound: bestRound,
      answersGiven: answersGiven,
      correctAnswers: correctAnswers,
      questionsSeen: stats.length,
      masteredQuestions: mastered,
      questionsToPractise: toPractise,
    );
  }

  /// Most recently played rounds, newest first.
  static Future<List<RoundResult>> recentRounds({int limit = 20}) async {
    final isar = Repository.isar;
    final rounds =
        await isar.roundResults.where().sortByPlayedAtDesc().findAll();
    return rounds.take(limit).toList();
  }

  /// Clears every per-question statistic.
  static Future<void> clear() async {
    final isar = Repository.isar;
    await isar.writeTxn(() async {
      await isar.questionStats.clear();
    });
  }
}
