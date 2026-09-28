import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/category.dart';

void main() {
  group('Category.recordScore', () {
    test('stores a better score and reports the record', () {
      final category = Category(
        categoryId: 'sports',
        name: 'Sports',
        highestScore: 3,
      );

      expect(category.recordScore(5), isTrue);
      expect(category.highestScore, 5);
    });

    test('keeps the existing best score', () {
      final category = Category(
        categoryId: 'sports',
        name: 'Sports',
        highestScore: 8,
      );

      expect(category.recordScore(2), isFalse);
      expect(category.highestScore, 8);
    });

    test('a tie does not rewrite the record', () {
      final category = Category(
        categoryId: 'sports',
        name: 'Sports',
        highestScore: 8,
      );

      expect(category.recordScore(8), isFalse);
    });
  });
}
