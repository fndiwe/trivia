import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/trivia.dart';

void main() {
  group('Trivia.tryFromMap', () {
    test('parses a well-formed record', () {
      final trivia = Trivia.tryFromMap({
        'question': 'Which planet is closest to the sun?',
        'category': 'science-technology',
        'answer': 'Mercury',
        'choices': ['Venus', 'Mercury', 'Mars', 'Earth'],
      });

      expect(trivia, isNotNull);
      expect(trivia!.question, 'Which planet is closest to the sun?');
      expect(trivia.category, 'science-technology');
      expect(trivia.answer, 'Mercury');
      expect(trivia.choices, ['Venus', 'Mercury', 'Mars', 'Earth']);
      expect(trivia.level, 0);
    });

    test('rejects a record whose answer is not among the choices', () {
      expect(
        Trivia.tryFromMap({
          'question': 'Q',
          'category': 'c',
          'answer': 'nope',
          'choices': ['a', 'b'],
        }),
        isNull,
      );
    });

    test('rejects records with missing fields', () {
      expect(Trivia.tryFromMap({'question': 'Q'}), isNull);
      expect(
        Trivia.tryFromMap({'question': 'Q', 'category': 'c', 'answer': 'a'}),
        isNull,
      );
    });

    test('rejects records with fewer than two choices', () {
      expect(
        Trivia.tryFromMap({
          'question': 'Q',
          'category': 'c',
          'answer': 'a',
          'choices': ['a'],
        }),
        isNull,
      );
    });

    test('rejects records with the wrong field types', () {
      expect(
        Trivia.tryFromMap({
          'question': 42,
          'category': 'c',
          'answer': 'a',
          'choices': ['a', 'b'],
        }),
        isNull,
      );
    });

    test('coerces non-string choices to strings', () {
      final trivia = Trivia.tryFromMap({
        'question': 'Q',
        'category': 'c',
        'answer': '2',
        'choices': [1, 2, 3],
      });
      expect(trivia!.choices, ['1', '2', '3']);
    });
  });

  group('withLevel', () {
    test('returns a copy carrying the level without mutating the original', () {
      final trivia =
          Trivia.tryFromMap({
            'question': 'Q',
            'category': 'c',
            'answer': 'a',
            'choices': ['a', 'b'],
          })!;

      final leveled = trivia.withLevel(7);

      expect(leveled.level, 7);
      expect(leveled.question, trivia.question);
      expect(trivia.level, 0);
    });
  });
}
