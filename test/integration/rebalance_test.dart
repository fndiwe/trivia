import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/question_stat.dart';
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
    await isar!.writeTxn(() async {
      await isar!.trivias.clear();
      await isar!.levels.clear();
      await isar!.questionStats.clear();
      await isar!.settings.clear();
    });
    await _seedDifficultyBank(isar!);
  });

  void skipUnlessIsar() {
    if (isar == null) {
      markTestSkipped('libisar.so not present at build/isar/libisar.so');
    }
  }

  test(
    'rebalance moves failed questions to harder levels and vice versa',
    () async {
      skipUnlessIsar();

      // A question the player keeps getting wrong should climb the ladder...
      for (var i = 0; i < 10; i++) {
        await StatsRepository.recordAnswer(
          question: 'Easy question 0?',
          correct: false,
          category: 'sports',
        );
      }
      // ...and a question the player always gets right should slide down.
      for (var i = 0; i < 10; i++) {
        await StatsRepository.recordAnswer(
          question: 'Hard question 0?',
          correct: true,
          category: 'history',
        );
      }

      final summary = await ProgressRepository.rebalanceCampaign();

      expect(summary.rescoredQuestions, 2);
      expect(summary.movedQuestions, greaterThan(0));

      final failedEasy =
          await isar!.trivias
              .where()
              .questionEqualTo('Easy question 0?')
              .findFirst();
      final masteredHard =
          await isar!.trivias
              .where()
              .questionEqualTo('Hard question 0?')
              .findFirst();

      expect(failedEasy, isNotNull);
      expect(masteredHard, isNotNull);
      expect(
        failedEasy!.difficulty,
        greaterThan(masteredHard!.difficulty),
        reason:
            'failing an easy question should make it harder than a mastered hard one',
      );
      expect(
        failedEasy.level,
        greaterThan(masteredHard.level),
        reason: 'levels are partitioned by difficulty ascending',
      );
    },
  );

  test('rebalance keeps the question count and level count intact', () async {
    skipUnlessIsar();
    final summary = await ProgressRepository.rebalanceCampaign();
    expect(await isar!.trivias.count(), 40);
    expect(summary.levelCount, 4);
  });

  test('maybeRebalance is throttled by answer count and by time', () async {
    skipUnlessIsar();

    // Not enough answers yet: no rebalance.
    expect(await ProgressRepository.maybeRebalance(minAnswers: 50), isFalse);

    for (var i = 0; i < 60; i++) {
      await StatsRepository.recordAnswer(
        question: 'Easy question ${i % 20}?',
        correct: i.isEven,
        category: 'sports',
      );
    }
    final ran = await ProgressRepository.maybeRebalance(minAnswers: 50);
    expect(ran, isTrue);

    // Just ran: should be throttled by the lastRebalancedOn timestamp.
    expect(await ProgressRepository.maybeRebalance(minAnswers: 50), isFalse);
  });
}

Future<void> _seedDifficultyBank(Isar isar) async {
  final questions = <Trivia>[
    for (var i = 0; i < 20; i++)
      Trivia(
        question: 'Easy question $i?',
        answer: 'Yes',
        choices: const ['Yes', 'No'],
        category: 'sports',
        level: 1,
        difficulty: 0.1,
      ),
    for (var i = 0; i < 20; i++)
      Trivia(
        question: 'Hard question $i?',
        answer: 'Yes',
        choices: const ['Yes', 'No'],
        category: 'history',
        level: 2,
        difficulty: 0.8,
      ),
  ];

  await isar.writeTxn(() async {
    await isar.trivias.putAll(questions);
    await isar.levels.putAll([
      Level(id: 1, score: 0),
      Level(id: 2),
      Level(id: 3),
      Level(id: 4),
    ]);
    await isar.settings.put(Settings());
  });
}
