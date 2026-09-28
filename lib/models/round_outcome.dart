import 'package:trivia/models/answered_question.dart';
import 'package:trivia/models/quiz_request.dart';

/// Everything the results screen needs about a finished round.
///
/// Previously the game screen pushed six loose constructor arguments at the
/// result screen and the result screen worked out what to persist. The outcome
/// is now a single value object.
class RoundOutcome {
  const RoundOutcome({
    required this.request,
    required this.score,
    required this.answers,
  });

  final QuizRequest request;
  final int score;

  /// Every question of the round, in the order it was asked.
  final List<AnsweredQuestion> answers;

  int get total => answers.length;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  List<AnsweredQuestion> get mistakes =>
      answers.where((answer) => !answer.isCorrect).toList();
}
