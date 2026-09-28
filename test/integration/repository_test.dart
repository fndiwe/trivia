import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/repository/quiz_repository.dart';

import 'isar_env.dart';

void main() {
  Isar? isar;

  setUpAll(() async {
    isar = await openTestIsar();
    if (isar == null) return;
    await seedTestBank(isar!);
  });

  void skipUnlessIsar() {
    if (isar == null) {
      // The native library is not available on this machine; skip.
      markTestSkipped('libisar.so not present at build/isar/libisar.so');
    }
  }

  group('QuizRepository', () {
    test('level questions come only from that level', () async {
      skipUnlessIsar();
      final questions = await QuizRepository.levelQuestions(1, 10);
      expect(questions, hasLength(10));
      expect(questions.every((q) => q.level == 1), isTrue);
      expect(questions.every((q) => q.category == 'sports'), isTrue);
    });

    test('level questions are capped by the pool size', () async {
      skipUnlessIsar();
      final questions = await QuizRepository.levelQuestions(2, 100);
      expect(questions, hasLength(25));
      expect(questions.every((q) => q.level == 2), isTrue);
    });

    test('category questions come only from that category', () async {
      skipUnlessIsar();
      final questions = await QuizRepository.categoryQuestions('sports', 10);
      expect(questions, hasLength(10));
      expect(questions.every((q) => q.category == 'sports'), isTrue);
    });

    test('a seeded pick is reproducible and duplicate-free', () async {
      skipUnlessIsar();
      final first = await QuizRepository.categoryQuestions(
        'history',
        15,
        random: Random(42),
      );
      final second = await QuizRepository.categoryQuestions(
        'history',
        15,
        random: Random(42),
      );
      expect(first.map((q) => q.id), second.map((q) => q.id));
      expect(first.toSet(), hasLength(first.length));
    });

    test('the daily challenge is the same for the same date', () async {
      skipUnlessIsar();
      final day = DateTime(2026, 3, 7);
      final first = await QuizRepository.dailyChallengeQuestions(
        10,
        today: day,
        random: Random(1),
      );
      final second = await QuizRepository.dailyChallengeQuestions(
        10,
        today: day,
        random: Random(1),
      );
      expect(first, hasLength(10));
      expect(first.map((q) => q.id), second.map((q) => q.id));
    });

    test('questionsFor routes a QuizRequest by mode', () async {
      skipUnlessIsar();
      final practice = await QuizRepository.questionsFor(
        const QuizRequest.practice(),
        roundSize: 10,
      );
      expect(practice, isEmpty);
    });
  });
}
