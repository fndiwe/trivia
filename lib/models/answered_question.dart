import 'package:trivia/models/trivia.dart';

/// One question as it was actually shown during a round, with what the player
/// did about it.
///
/// The results screen needs this to render the answer review; it also makes the
/// "timed out" and "skipped" cases explicit, which the old score-only result
/// could not express.
class AnsweredQuestion {
  const AnsweredQuestion({
    required this.trivia,
    required this.presentedChoices,
    this.selectedChoice,
    this.timedOut = false,
  });

  final Trivia trivia;

  /// The choices in the order they were shown (they are reshuffled per round).
  final List<String> presentedChoices;

  /// What the player tapped, or `null` when they ran out of time or skipped.
  final String? selectedChoice;

  /// True when the countdown hit zero.
  final bool timedOut;

  bool get isCorrect =>
      selectedChoice != null && selectedChoice == trivia.answer;

  bool get wasAnswered => selectedChoice != null;

  /// Neither answered nor timed out - the player used a skip lifeline.
  bool get wasSkipped => selectedChoice == null && !timedOut;
}
