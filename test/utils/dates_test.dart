import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/dates.dart';

void main() {
  group('localDayOf', () {
    test('drops the time of day', () {
      expect(
        localDayOf(DateTime(2026, 3, 7, 23, 59, 59)),
        DateTime(2026, 3, 7),
      );
    });
  });

  group('isSameLocalDay', () {
    test('is true for two moments on the same day', () {
      expect(
        isSameLocalDay(DateTime(2026, 3, 7, 1), DateTime(2026, 3, 7, 22)),
        isTrue,
      );
    });

    test('is false across midnight', () {
      expect(
        isSameLocalDay(
          DateTime(2026, 3, 7, 23, 59),
          DateTime(2026, 3, 8, 0, 1),
        ),
        isFalse,
      );
    });
  });

  group('daysBetween', () {
    test('ignores the time of day', () {
      expect(daysBetween(DateTime(2026, 3, 7, 23), DateTime(2026, 3, 8, 1)), 1);
    });

    test('handles month boundaries', () {
      expect(daysBetween(DateTime(2026, 1, 31), DateTime(2026, 2, 1)), 1);
    });
  });

  group('isNextLocalDay', () {
    test('is true only for the immediately following day', () {
      expect(
        isNextLocalDay(DateTime(2026, 3, 8), DateTime(2026, 3, 7)),
        isTrue,
      );
      expect(
        isNextLocalDay(DateTime(2026, 3, 9), DateTime(2026, 3, 7)),
        isFalse,
      );
      expect(
        isNextLocalDay(DateTime(2026, 3, 7), DateTime(2026, 3, 7)),
        isFalse,
      );
    });
  });

  group('dailySeedFor', () {
    test('is stable for a given day and different across days', () {
      expect(
        dailySeedFor(DateTime(2026, 3, 7)),
        dailySeedFor(DateTime(2026, 3, 7)),
      );
      expect(
        dailySeedFor(DateTime(2026, 3, 7)),
        isNot(dailySeedFor(DateTime(2026, 3, 8))),
      );
      expect(
        dailySeedFor(DateTime(2026, 3, 7)),
        isNot(dailySeedFor(DateTime(2027, 3, 7))),
      );
    });
  });

  group('streakAfterRound', () {
    final today = DateTime(2026, 3, 7, 20);

    test('starts at one for a first ever round', () {
      expect(
        streakAfterRound(today: today, lastPlayedOn: null, currentStreak: 0),
        1,
      );
    });

    test('does not grow twice in one day', () {
      expect(
        streakAfterRound(
          today: today,
          lastPlayedOn: DateTime(2026, 3, 7, 8),
          currentStreak: 4,
        ),
        4,
      );
    });

    test('grows when yesterday was played', () {
      expect(
        streakAfterRound(
          today: today,
          lastPlayedOn: DateTime(2026, 3, 6, 23),
          currentStreak: 4,
        ),
        5,
      );
    });

    test('resets after a missed day', () {
      expect(
        streakAfterRound(
          today: today,
          lastPlayedOn: DateTime(2026, 3, 4),
          currentStreak: 9,
        ),
        1,
      );
    });
  });
}
