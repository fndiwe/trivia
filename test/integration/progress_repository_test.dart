import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/repository/stats_repository.dart';

import 'isar_env.dart';

void main() {
  Isar? isar;

  setUp(() async {
    isar ??= await openTestIsar();
    if (isar == null) return;
    // Start every test from a fresh bank: cheap enough at this size and it
    // keeps the assertions independent of test order.
    await isar!.writeTxn(() async {
      await isar!.trivias.clear();
      await isar!.levels.clear();
      await isar!.categorys.clear();
      await isar!.roundResults.clear();
      await isar!.questionStats.clear();
      await isar!.settings.clear();
    });
    await seedTestBank(isar!);
  });

  void skipUnlessIsar() {
    if (isar == null) {
      markTestSkipped('libisar.so not present at build/isar/libisar.so');
    }
  }

  group('saveRound', () {
    test(
      'writes the round, the level score and unlocks the next level',
      () async {
        skipUnlessIsar();
        final summary = await ProgressRepository.saveRound(
          mode: RoundMode.level,
          score: 8,
          total: 10,
          levelId: 1,
          playedAt: DateTime(2026, 3, 7),
        );

        expect(summary.score, 8);
        expect(summary.unlockedLevelId, 2);
        expect(summary.streak, 1);
        expect(summary.streakIncreased, isTrue);

        final level1 = await isar!.levels.get(1);
        final level2 = await isar!.levels.get(2);
        expect(level1?.score, 8);
        expect(level2?.score, 0);

        final rounds = await isar!.roundResults.where().findAll();
        expect(rounds, hasLength(1));
        expect(rounds.single.mode, RoundMode.level);
      },
    );

    test('a category best score only grows', () async {
      skipUnlessIsar();
      await ProgressRepository.saveRound(
        mode: RoundMode.category,
        score: 18,
        total: 20,
        categoryId: 'sports',
        playedAt: DateTime(2026, 3, 7),
      );
      final worse = await ProgressRepository.saveRound(
        mode: RoundMode.category,
        score: 9,
        total: 20,
        categoryId: 'sports',
        playedAt: DateTime(2026, 3, 7),
      );
      expect(worse.newCategoryBest, isFalse);

      final category =
          await isar!.categorys.where().categoryIdEqualTo('sports').findFirst();
      expect(category?.highestScore, 18);
    });

    test(
      'the streak grows on consecutive days and resets after a gap',
      () async {
        skipUnlessIsar();
        final day1 = await ProgressRepository.saveRound(
          mode: RoundMode.category,
          score: 5,
          total: 10,
          categoryId: 'sports',
          playedAt: DateTime(2026, 3, 7),
        );
        expect(day1.streak, 1);

        final day2 = await ProgressRepository.saveRound(
          mode: RoundMode.category,
          score: 5,
          total: 10,
          categoryId: 'sports',
          playedAt: DateTime(2026, 3, 8),
        );
        expect(day2.streak, 2);
        expect(day2.longestStreak, 2);

        // Same day again: no double-count.
        final sameDay = await ProgressRepository.saveRound(
          mode: RoundMode.category,
          score: 5,
          total: 10,
          categoryId: 'sports',
          playedAt: DateTime(2026, 3, 8, 23),
        );
        expect(sameDay.streak, 2);
        expect(sameDay.streakIncreased, isFalse);

        final afterGap = await ProgressRepository.saveRound(
          mode: RoundMode.category,
          score: 5,
          total: 10,
          categoryId: 'sports',
          playedAt: DateTime(2026, 3, 20),
        );
        expect(afterGap.streak, 1);
      },
    );

    test('the daily challenge is stamped on the settings row', () async {
      skipUnlessIsar();
      await ProgressRepository.saveRound(
        mode: RoundMode.daily,
        score: 7,
        total: 10,
        playedAt: DateTime(2026, 3, 7),
      );
      final settings = await isar!.settings.get(1);
      expect(settings?.dailyChallengeCompletedOn, isNotNull);
    });
  });

  group('practice queue', () {
    test('wrong answers are queued and offered for practice', () async {
      skipUnlessIsar();
      await StatsRepository.recordAnswer(
        question: 'Sports question 1?',
        correct: false,
      );
      await StatsRepository.recordAnswer(
        question: 'Sports question 2?',
        correct: true,
      );

      final queue = await StatsRepository.practiceQueue();
      expect(queue, hasLength(1));
      expect(queue.single.question, 'Sports question 1?');

      final practice = await StatsRepository.load();
      expect(practice.questionsToPractise, 1);
      expect(practice.masteredQuestions, 1);
    });
  });

  group('resetProgress', () {
    test('re-locks levels, clears scores, history and statistics', () async {
      skipUnlessIsar();
      await ProgressRepository.saveRound(
        mode: RoundMode.level,
        score: 8,
        total: 10,
        levelId: 1,
        playedAt: DateTime(2026, 3, 7),
      );
      await StatsRepository.recordAnswer(
        question: 'Sports question 1?',
        correct: false,
      );

      await ProgressRepository.resetProgress();

      final level1 = await isar!.levels.get(1);
      final level2 = await isar!.levels.get(2);
      expect(level1?.score, 0);
      expect(level2?.score, isNull);
      expect(await isar!.roundResults.count(), 0);
      expect(await isar!.questionStats.count(), 0);

      final category =
          await isar!.categorys.where().categoryIdEqualTo('sports').findFirst();
      expect(category?.highestScore, 0);

      final settings = await isar!.settings.get(1);
      expect(settings?.currentStreak, 0);
    });
  });
}
