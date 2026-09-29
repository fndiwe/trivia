/// What a campaign rebalance did.
class RebalanceSummary {
  const RebalanceSummary({
    required this.levelCount,
    required this.rescoredQuestions,
    required this.movedQuestions,
  });

  /// Total levels in the campaign.
  final int levelCount;

  /// Questions whose difficulty was re-estimated from the player's statistics
  /// (the rest kept their intrinsic estimate).
  final int rescoredQuestions;

  /// Questions that moved to a different level as a result.
  final int movedQuestions;

  bool get anythingMoved => movedQuestions > 0;
}
