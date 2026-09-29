import 'package:isar/isar.dart';

part 'trivia.g.dart';

@collection
class Trivia {
  Id id = Isar.autoIncrement;

  @Index()
  final String category;

  /// Indexed because every level round filters on it; without an index each
  /// round start was a full table scan over the whole question bank.
  @Index()
  final int level;

  /// Indexed so per-question statistics can be looked up by text (see
  /// `QuestionStat`), which keeps them stable across re-imports.
  @Index()
  final String question;

  /// Estimated `0..1` difficulty (higher = harder). Set at import time from
  /// the question content, and refined from the player's statistics when the
  /// campaign is rebalanced. Indexed so levels can be ordered by it.
  @Index()
  final double difficulty;

  final String answer;
  final List<String> choices;

  Trivia({
    required this.question,
    required this.answer,
    required this.choices,
    required this.category,
    this.level = 0,
    this.difficulty = 0.5,
  });

  /// Parses one record of the bundled `assets/trivia.json`.
  ///
  /// Returns `null` for malformed entries instead of throwing, so a single bad
  /// record in the asset cannot abort the first-launch import.
  static Trivia? tryFromMap(Map<String, dynamic> map) {
    final question = map['question'];
    final answer = map['answer'];
    final category = map['category'];
    final choices = map['choices'];

    if (question is! String ||
        answer is! String ||
        category is! String ||
        choices is! List ||
        choices.isEmpty) {
      return null;
    }

    final parsedChoices = choices
        .whereType<Object>()
        .map((choice) => choice.toString())
        .toList(growable: false);
    if (parsedChoices.length < 2 || !parsedChoices.contains(answer)) {
      return null;
    }

    return Trivia(
      question: question,
      answer: answer,
      choices: parsedChoices,
      category: category,
    );
  }

  static Trivia fromMap(Map<String, dynamic> map) => Trivia(
    question: map['question'],
    answer: map['answer'],
    choices: (map['choices'] as List).map((item) => item.toString()).toList(),
    category: map['category'],
  );

  /// Returns a copy in another level. The Isar [id] is preserved, so the
  /// copy can be used to *update* the stored row (during import the id is the
  /// auto-increment sentinel and a new row is created, which is what we want).
  Trivia withLevel(int level) => Trivia(
    question: question,
    answer: answer,
    choices: choices,
    category: category,
    level: level,
    difficulty: difficulty,
  )..id = id;

  /// Returns a copy with a new [difficulty]; the Isar [id] is preserved so the
  /// copy can update the stored row.
  Trivia withDifficulty(double difficulty) => Trivia(
    question: question,
    answer: answer,
    choices: choices,
    category: category,
    level: level,
    difficulty: difficulty,
  )..id = id;
}
