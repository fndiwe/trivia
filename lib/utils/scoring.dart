/// Pure scoring rules for a quiz round.
///
/// Deliberately free of Flutter/Isar imports so the rules can be unit tested
/// without booting a widget tree or a database.
library;

/// Maximum number of stars a single round can award.
const int maxStars = 3;

/// Number of questions in one campaign level.
///
/// Levels are partitioned at import time, so this is fixed rather than a
/// setting: changing it would silently re-map every unlocked level.
const int questionsPerLevel = 10;

/// Default length of a category (free-play) round.
const int defaultCategoryRoundSize = 20;

/// Round lengths offered by the "questions per category round" setting.
const List<int> categoryRoundSizeOptions = [10, 15, 20, 30];

/// Number of questions in the daily challenge.
const int dailyChallengeLength = 10;

/// Upper bound on the number of questions in a "practise your mistakes" round.
const int practiceRoundLength = 15;

/// Default number of seconds a player gets per question.
const int defaultSecondsPerQuestion = 30;

/// Timer durations offered by the settings screen (0 disables the timer).
const List<int> timerOptions = [0, 15, 30, 45, 60];

/// Converts a raw score into a `0..maxStars` rating.
///
/// Returns `0` for degenerate rounds (no questions) rather than producing
/// `NaN`, which is what `(score / 0).round()` used to do while questions were
/// still loading.
int starsFor(int score, int total) {
  if (total <= 0) return 0;
  final safeScore = score.clamp(0, total);
  return ((safeScore / total) * maxStars).round().clamp(0, maxStars);
}

/// The end-of-round sting: a cheer for a good result, a soft "aww" otherwise.
String resultSoundAsset(int score, int total) =>
    starsFor(score, total) >= 2
        ? 'assets/audio/applause.mp3'
        : 'assets/audio/aww.mp3';

/// Number of questions a round actually contains, accounting for pools that
/// are smaller than the configured round size (small categories, final level).
int roundSize({required int requested, required int available}) {
  if (available <= 0) return 0;
  return requested < available ? requested : available;
}
