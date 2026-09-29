import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/utils/scoring.dart';

/// What the game screen was asked to play.
///
/// The route argument used to be a bare `Level` or `Category`; the daily
/// challenge and the practice mode have neither, so the request is now explicit
/// and the router never has to guess the type.
class QuizRequest {
  const QuizRequest._({required this.mode, this.level, this.category});

  const QuizRequest.level(Level level)
    : this._(mode: RoundMode.level, level: level);

  const QuizRequest.category(Category category)
    : this._(mode: RoundMode.category, category: category);

  const QuizRequest.daily() : this._(mode: RoundMode.daily);

  const QuizRequest.practice() : this._(mode: RoundMode.practice);

  final RoundMode mode;
  final Level? level;
  final Category? category;

  /// How many questions a round of this kind contains.
  ///
  /// Campaign levels are a fixed length (they are partitioned at import time),
  /// categories honour the player's preference, and the daily challenge and
  /// practice modes have their own sensible bounds.
  int roundSizeFor({required int categoryRoundSize}) {
    switch (mode) {
      case RoundMode.level:
        return questionsPerLevel;
      case RoundMode.category:
        return categoryRoundSize;
      case RoundMode.daily:
        return dailyChallengeLength;
      case RoundMode.practice:
        return practiceRoundLength;
    }
  }
}
