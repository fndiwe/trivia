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

  final String question;
  final String answer;
  final List<String> choices;

  Trivia({
    required this.question,
    required this.answer,
    required this.choices,
    required this.category,
    this.level = 0,
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

  Trivia withLevel(int level) => Trivia(
    question: question,
    answer: answer,
    choices: choices,
    category: category,
    level: level,
  );
}

