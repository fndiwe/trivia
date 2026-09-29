import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/utils/scoring.dart';

void main() {
  group('QuizRequest', () {
    test('carries the level for a campaign round', () {
      final request = QuizRequest.level(Level(id: 3, score: 4));
      expect(request.mode, RoundMode.level);
      expect(request.level?.id, 3);
      expect(request.category, isNull);
    });

    test('carries the category for free play', () {
      final request = QuizRequest.category(
        Category(categoryId: 'sports', name: 'Sports'),
      );
      expect(request.mode, RoundMode.category);
      expect(request.category?.categoryId, 'sports');
      expect(request.level, isNull);
    });

    test('daily and practice rounds need neither a level nor a category', () {
      expect(const QuizRequest.daily().level, isNull);
      expect(const QuizRequest.daily().category, isNull);
      expect(const QuizRequest.practice().mode, RoundMode.practice);
    });
  });

  group('roundSizeFor', () {
    test('levels are always questionsPerLevel long', () {
      expect(
        QuizRequest.level(Level(id: 1)).roundSizeFor(categoryRoundSize: 30),
        questionsPerLevel,
      );
    });

    test('categories honour the player preference', () {
      expect(
        QuizRequest.category(
          Category(categoryId: 'sports', name: 'Sports'),
        ).roundSizeFor(categoryRoundSize: 15),
        15,
      );
    });

    test('the daily challenge has a fixed length', () {
      expect(
        const QuizRequest.daily().roundSizeFor(categoryRoundSize: 30),
        dailyChallengeLength,
      );
    });

    test('practice is bounded', () {
      expect(
        const QuizRequest.practice().roundSizeFor(categoryRoundSize: 30),
        practiceRoundLength,
      );
    });
  });
}
