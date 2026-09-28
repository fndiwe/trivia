/// What changed in the database when a round finished.
///
/// Returned by `ProgressRepository.saveRound` so the results screen can show
/// the right badges without re-reading anything.
class RoundSummary {
  const RoundSummary({
    required this.score,
    required this.total,
    required this.stars,
    this.newCategoryBest = false,
    this.unlockedLevelId,
    this.streak = 0,
    this.streakIncreased = false,
    this.longestStreak = 0,
    this.practiceQuestionCount = 0,
  });

  final int score;
  final int total;

  /// 0..[maxStars] rating for this round.
  final int stars;

  /// True when this round set a new best score for the category.
  final bool newCategoryBest;

  /// Level that this round unlocked, if any.
  final int? unlockedLevelId;

  /// Current day streak after this round.
  final int streak;
  final bool streakIncreased;
  final int longestStreak;

  /// How many questions are currently queued for "practise your mistakes".
  final int practiceQuestionCount;

  bool get isPerfect => total > 0 && score >= total;
}
