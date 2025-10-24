import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/utils/categories.dart';

Future<void> extractDataToDatabase() async {
  final isar = Repository.isar;
  // Load the JSON string from the asset file
  final String jsonString = await rootBundle.loadString('assets/trivia.json');
  final List<dynamic> triviaList = jsonDecode(jsonString);
  final random = triviaList..shuffle();
  await isar.writeTxn(() async {
    // Trivial data
    for (int i = 0; i < random.length; i++) {
      final triviaMap = random[i];
      final trivia = Trivia.fromMap(triviaMap);
      final triviaWithLevel = Trivia(
        question: trivia.question,
        answer: trivia.answer,
        choices: trivia.choices,
        category: trivia.category,
        level: (i ~/ 10) + 1, // Assign level based on index
      );
      await isar.trivias.put(triviaWithLevel);
    }
    // Levels data
    for (int i = 1; i <= (random.length / 10) + 1; i++) {
      final level = Level(id: i, score: null);
      await isar.levels.put(level);
    }
    // Categories data
    final categories = Categories.categories;
    for (final category in categories) {
      final numberOfQuestions =
          await isar.trivias
              .filter()
              .categoryEqualTo(category.categoryId)
              .count();
      final categoryWithCount = Category(
        categoryId: category.categoryId,
        name: category.name,
        numberOfQuestions: numberOfQuestions,
        highestScore: 0,
      );
      await isar.categorys.put(categoryWithCount);
    }
  });
}
