/// Small date helpers used by the streak and daily-challenge logic.
///
/// Kept pure (no `DateTime.now()` inside) so they can be unit tested with fixed
/// dates.
library;

/// Midnight of the local day [moment] falls on.
DateTime localDayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Whether [a] and [b] are the same local calendar day.
bool isSameLocalDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Whether [later] is exactly the day after [earlier].
bool isNextLocalDay(DateTime later, DateTime earlier) =>
    daysBetween(earlier, later) == 1;

/// Whole days between two dates, ignoring the time of day.
int daysBetween(DateTime from, DateTime to) =>
    localDayOf(to).difference(localDayOf(from)).inDays;

/// Stable per-day seed for the daily challenge.
///
/// Every device installing the same question bank gets the same ten questions
/// on the same day, because the seed only depends on the calendar date.
int dailySeedFor(DateTime day) =>
    (day.year * 10000) + (day.month * 100) + day.day;

/// The streak a player should have after finishing a round on [today], given
/// the last day they played ([lastPlayedOn]) and their current streak.
///
/// * never played before           -> 1
/// * already played today          -> unchanged
/// * played yesterday              -> previous streak + 1
/// * anything older                -> 1 (the streak was broken)
int streakAfterRound({
  required DateTime today,
  required DateTime? lastPlayedOn,
  required int currentStreak,
}) {
  if (lastPlayedOn == null) return 1;
  if (isSameLocalDay(today, lastPlayedOn)) {
    return currentStreak < 1 ? 1 : currentStreak;
  }
  if (isNextLocalDay(today, lastPlayedOn)) return currentStreak + 1;
  return 1;
}
