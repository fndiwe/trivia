import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/quiz_selection.dart';

void main() {
  group('pickRandom', () {
    test('returns the whole pool when it is smaller than the request', () {
      final pool = [1, 2, 3];
      final picked = pickRandom(pool, 10, random: Random(1));
      expect(picked, hasLength(3));
      expect(picked.toSet(), {1, 2, 3});
    });

    test('returns exactly count items', () {
      final pool = List<int>.generate(50, (index) => index);
      expect(pickRandom(pool, 20, random: Random(7)), hasLength(20));
    });

    test('never returns duplicates', () {
      final pool = List<int>.generate(50, (index) => index);
      final picked = pickRandom(pool, 20, random: Random(7));
      expect(picked.toSet(), hasLength(picked.length));
    });

    test('picks a different set on a different seed', () {
      final pool = List<int>.generate(50, (index) => index);
      final first = pickRandom(pool, 20, random: Random(1));
      final second = pickRandom(pool, 20, random: Random(2));
      expect(first, isNot(equals(second)));
    });

    test('does not mutate the pool', () {
      final pool = List<int>.generate(10, (index) => index);
      final before = List<int>.of(pool);
      pickRandom(pool, 3, random: Random(3));
      expect(pool, before);
    });

    test('returns an empty list for a non-positive count', () {
      expect(pickRandom([1, 2, 3], 0), isEmpty);
      expect(pickRandom([1, 2, 3], -1), isEmpty);
    });

    test('returns an empty list for an empty pool', () {
      expect(pickRandom(<int>[], 10), isEmpty);
    });
  });
}
