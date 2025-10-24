import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;
  final String categoryId;
  final String name;
  int numberOfQuestions;
  int highestScore;

  Category({required this.categoryId, required this.name, this.numberOfQuestions = 0, this.highestScore = 0});


  Category changeScore(int highestScore) => this..highestScore = highestScore;
}
