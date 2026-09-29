import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/difficulty.dart';

void main() {
  group('similarity', () {
    test('identical strings score 1', () {
      expect(similarity('mercury', 'mercury'), 1.0);
    });

    test('is case-insensitive', () {
      expect(similarity('Mercury', 'MERCURY'), 1.0);
    });

    test('empty strings behave sensibly', () {
      expect(similarity('', 'x'), 0.0);
      expect(similarity('', ''), 1.0);
    });

    test('similar strings score higher than dissimilar ones', () {
      final similar = similarity('Kitten', 'Sitting');
      final dissimilar = similarity('Mercury', 'Banana');
      expect(similar, greaterThan(dissimilar));
    });
  });

  group('editDistance', () {
    test('the classic kitten/sitting example', () {
      expect(editDistance('kitten', 'sitting'), 3);
    });

    test('empty versus non-empty is the other length', () {
      expect(editDistance('', 'abc'), 3);
      expect(editDistance('abc', ''), 3);
    });

    test('identical strings have zero distance', () {
      expect(editDistance('trivia', 'trivia'), 0);
    });
  });

  group('estimateDifficulty', () {
    test('a numeric answer is harder than a textual one, all else equal', () {
      final numeric = estimateDifficulty(
        question: 'How many bones are in the human body?',
        answer: '206',
        choices: const ['206', '187', '215', '193'],
      );
      final textual = estimateDifficulty(
        question: 'Which bone is the longest in the human body?',
        answer: 'Femur',
        choices: const ['Femur', 'Tibia', 'Fibula', 'Humerus'],
      );
      expect(numeric, greaterThan(textual));
    });

    test('confusing distractors make a question harder', () {
      final confusing = estimateDifficulty(
        question: 'Which element has the symbol Fe?',
        answer: 'Iron',
        choices: const ['Iron', 'Iridium', 'Iodine', 'Indium'],
      );
      final clear = estimateDifficulty(
        question: 'Which element has the symbol Fe?',
        answer: 'Iron',
        choices: const ['Iron', 'Gold', 'Zinc', 'Lead'],
      );
      expect(confusing, greaterThan(clear));
    });

    test('longer questions are harder than short ones', () {
      final short = estimateDifficulty(
        question: 'Capital of France?',
        answer: 'Paris',
        choices: const ['Paris', 'Lyon', 'Nice', 'Lille'],
      );
      final long = estimateDifficulty(
        question:
            'Considering the historical development of European capitals '
            'throughout the medieval period and the subsequent political '
            'consolidation of nation states, which city serves as the '
            'administrative and cultural capital of France?',
        answer: 'Paris',
        choices: const ['Paris', 'Lyon', 'Nice', 'Lille'],
      );
      expect(long, greaterThan(short));
    });

    test('the result stays within 0 and 1', () {
      final extreme = estimateDifficulty(
        question: 'a' * 400,
        answer: 'answer',
        choices: const ['answer', 'answer'],
      );
      expect(extreme, inInclusiveRange(0, 1));
    });
  });

  group('posteriorDifficulty', () {
    test('with no answers it returns the intrinsic estimate', () {
      expect(posteriorDifficulty(correct: 0, shown: 0, intrinsic: 0.7), 0.7);
    });

    test('a mastered question becomes easier than its intrinsic estimate', () {
      final difficulty = posteriorDifficulty(
        correct: 10,
        shown: 10,
        intrinsic: 0.8,
      );
      expect(difficulty, lessThan(0.8));
    });

    test('a repeatedly failed question becomes harder', () {
      final difficulty = posteriorDifficulty(
        correct: 0,
        shown: 10,
        intrinsic: 0.2,
      );
      expect(difficulty, greaterThan(0.2));
    });

    test('more answers move the estimate closer to the observation', () {
      final few = posteriorDifficulty(correct: 1, shown: 2, intrinsic: 0.5);
      final many = posteriorDifficulty(correct: 5, shown: 10, intrinsic: 0.5);
      // Both have 50% observed accuracy; more data should pull harder toward
      // the observed 50% (i.e. difficulty ~0.5 is already close, so compare
      // against a mastered trend instead).
      final masteredFew = posteriorDifficulty(
        correct: 2,
        shown: 2,
        intrinsic: 0.9,
      );
      final masteredMany = posteriorDifficulty(
        correct: 10,
        shown: 10,
        intrinsic: 0.9,
      );
      expect(masteredMany, lessThan(masteredFew));
      expect(few, inInclusiveRange(0, 1));
      expect(many, inInclusiveRange(0, 1));
    });
  });
}
