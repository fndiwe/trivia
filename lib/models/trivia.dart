import 'package:isar/isar.dart';

part 'trivia.g.dart';

@collection
class Trivia {
  Id id = Isar.autoIncrement;
  final String question;
  final String answer;
  final List<String> choices;
  @Index()
  final String category;
  late int level;

  Trivia({
    required this.question,
    required this.answer,
    required this.choices,
    required this.category,
    this.level = 0,
  });

  static Trivia fromMap(Map<String, dynamic> map) => Trivia(
    question: map["question"],
    answer: map["answer"],
    choices: (map["choices"] as List).map((item) => item.toString()).toList(),
    category: map["category"],
  );
}
