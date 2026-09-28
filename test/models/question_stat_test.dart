import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/round_result.dart';

void main() {
  group('QuestionStat', () {
    test('starts unseen', () {
      final stat = QuestionStat(question: 'Q');
      expect(stat.timesShown, 0);
      expect(stat.timesCorrect, 0);
      expect(stat.accuracy, 0);
      expect(stat.needsPractice, isFalse);
      expect(stat.isMastered, isFalse);
    });

    test('records correct and wrong answers', () {
      final stat = QuestionStat(question: 'Q');
      stat.record(correct: true, at: DateTime(2026, 1, 1));
      stat.record(correct: false, at: DateTime(2026, 1, 2));
      expect(stat.timesShown, 2);
      expect(stat.timesCorrect, 1);
      expect(stat.accuracy, 0.5);
      expect(stat.needsPractice, isTrue);
      expect(stat.isMastered, isFalse);
      expect(stat.lastAnsweredAt, DateTime(2026, 1, 2));
    });

    test('counts as mastered once answered correctly every time', () {
      final stat = QuestionStat(question: 'Q');
      stat.record(correct: true, at: DateTime(2026, 1, 1));
      expect(stat.isMastered, isTrue);
      expect(stat.needsPractice, isFalse);
      expect(stat.accuracy, 1);
    });
  });

  group('RoundResult', () {
    test('derives the star rating from the score', () {
      final round = RoundResult(
        playedAt: DateTime(2026, 1, 1),
        mode: RoundMode.category,
        score: 10,
        total: 10,
      );
      expect(round.stars, 3);
      expect(round.accuracy, 1);
    });

    test('round-trips the mode through its stored name', () {
      for (final mode in RoundMode.values) {
        final round = RoundResult(
          playedAt: DateTime(2026, 1, 1),
          mode: mode,
          score: 1,
          total: 2,
        );
        expect(round.mode, mode);
      }
    });
  });
}
