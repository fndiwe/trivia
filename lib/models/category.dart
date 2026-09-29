import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  /// Stable slug used by the bundled SVGs (`assets/images/<categoryId>.svg`) and
  /// by the question bank's `category` field.
  @Index()
  final String categoryId;

  final String name;

  /// Total questions available for this category (denormalised at import time).
  int numberOfQuestions;

  /// Best score ever achieved in this category.
  int highestScore;

  Category({
    required this.categoryId,
    required this.name,
    this.numberOfQuestions = 0,
    this.highestScore = 0,
  });

  /// Records [score] as the new best score when it beats the current one.
  /// Returns `true` when the record was improved.
  bool recordScore(int score) {
    if (score <= highestScore) return false;
    highestScore = score;
    return true;
  }
}
