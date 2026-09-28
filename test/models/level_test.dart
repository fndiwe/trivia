import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/models/level.dart';

void main() {
  group('Level.isUnlocked', () {
    test('the first level is always unlocked', () {
      expect(Level(id: 1).isUnlocked, isTrue);
      expect(Level(id: 1, score: null).isUnlocked, isTrue);
    });

    test('a level is unlocked once it has any score, including zero', () {
      expect(Level(id: 4, score: 0).isUnlocked, isTrue);
      expect(Level(id: 4, score: 7).isUnlocked, isTrue);
    });

    test('a level with no score beyond the first is locked', () {
      expect(Level(id: 4).isUnlocked, isFalse);
    });
  });
}
