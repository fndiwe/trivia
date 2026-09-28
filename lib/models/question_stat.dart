import 'package:isar/isar.dart';

part 'question_stat.g.dart';

/// How a single question has gone for the player over time.
///
/// Keyed by the question text rather than by `Trivia.id`, because ids are
/// reassigned when the question bank is re-imported while the text is stable.
/// This is what powers the "practise your mistakes" mode and the per-category
/// accuracy statistics.
@collection
class QuestionStat {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String question;

  int timesShown = 0;
  int timesCorrect = 0;

  DateTime? lastAnsweredAt;

  QuestionStat({
    required this.question,
    this.timesShown = 0,
    this.timesCorrect = 0,
    this.lastAnsweredAt,
  });

  /// Ratio of correct answers, `0` for a question that has never been asked.
  @ignore
  double get accuracy => timesShown == 0 ? 0 : timesCorrect / timesShown;

  /// True once the question has been answered wrongly at least once.
  @ignore
  bool get needsPractice => timesShown > timesCorrect;

  /// True when the player has never got this question wrong.
  @ignore
  bool get isMastered => timesShown > 0 && timesCorrect == timesShown;

  void record({required bool correct, required DateTime at}) {
    timesShown++;
    if (correct) timesCorrect++;
    lastAnsweredAt = at;
  }
}
