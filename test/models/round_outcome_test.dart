import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/answered_question.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_outcome.dart';
import 'package:trivia/models/round_summary.dart';
import 'package:trivia/models/trivia.dart';

Trivia _trivia() => Trivia(
  question: 'Which planet is closest to the sun?',
  answer: 'Mercury',
  choices: const ['Mercury', 'Venus', 'Earth', 'Mars'],
  category: 'science-technology',
);

void main() {
  group('AnsweredQuestion', () {
    test('a correct pick is recognised', () {
      final answer = AnsweredQuestion(
        trivia: _trivia(),
        presentedChoices: const ['Venus', 'Mercury'],
        selectedChoice: 'Mercury',
      );
      expect(answer.isCorrect, isTrue);
      expect(answer.wasAnswered, isTrue);
      expect(answer.wasSkipped, isFalse);
    });

    test('a wrong pick is recognised', () {
      final answer = AnsweredQuestion(
        trivia: _trivia(),
        presentedChoices: const ['Mercury', 'Venus'],
        selectedChoice: 'Venus',
      );
      expect(answer.isCorrect, isFalse);
      expect(answer.wasAnswered, isTrue);
    });

    test('a timeout is neither answered nor skipped', () {
      final answer = AnsweredQuestion(
        trivia: _trivia(),
        presentedChoices: const ['Mercury', 'Venus'],
        timedOut: true,
      );
      expect(answer.isCorrect, isFalse);
      expect(answer.wasAnswered, isFalse);
      expect(answer.wasSkipped, isFalse);
    });

    test('a skip is distinguished from a timeout', () {
      final answer = AnsweredQuestion(
        trivia: _trivia(),
        presentedChoices: const ['Mercury', 'Venus'],
      );
      expect(answer.wasSkipped, isTrue);
      expect(answer.isCorrect, isFalse);
    });
  });

  group('RoundOutcome', () {
    RoundOutcome outcome() => RoundOutcome(
      request: const QuizRequest.daily(),
      score: 2,
      answers: [
        AnsweredQuestion(
          trivia: _trivia(),
          presentedChoices: const ['Mercury', 'Venus'],
          selectedChoice: 'Mercury',
        ),
        AnsweredQuestion(
          trivia: _trivia(),
          presentedChoices: const ['Mercury', 'Venus'],
          selectedChoice: 'Venus',
        ),
        AnsweredQuestion(
          trivia: _trivia(),
          presentedChoices: const ['Mercury', 'Venus'],
          timedOut: true,
        ),
      ],
    );

    test('counts the total and the mistakes', () {
      expect(outcome().total, 3);
      expect(outcome().mistakes, hasLength(2));
    });

    test('counts the correct answers', () {
      expect(outcome().correctCount, 1);
    });
  });

  group('RoundSummary', () {
    test('knows when a round was perfect', () {
      const perfect = RoundSummary(score: 10, total: 10, stars: 3);
      const imperfect = RoundSummary(score: 9, total: 10, stars: 3);
      expect(perfect.isPerfect, isTrue);
      expect(imperfect.isPerfect, isFalse);
    });

    test('an empty round is never perfect', () {
      expect(
        const RoundSummary(score: 0, total: 0, stars: 0).isPerfect,
        isFalse,
      );
    });
  });
}
