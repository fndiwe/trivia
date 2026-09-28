import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/utils/categories.dart';
import 'package:trivia/utils/scoring.dart';

/// Bump this whenever `assets/trivia.json` changes.
///
/// The import is re-run when the stored version in settings does not match, so
/// shipping a new question bank no longer requires users to reinstall the app.
/// Re-importing rebuilds the level ladder, so level progress restarts.
const int currentQuestionBankVersion = 1;

/// Loads the bundled question bank into Isar.
///
/// Improvements over the original import:
///
/// * malformed records are skipped instead of aborting the whole import,
/// * questions are written with `putAll` inside a single transaction,
/// * level 1 is created already unlocked (score `0`) so it matches
///   [Level.isUnlocked] instead of relying on a special case,
/// * the wasted empty level at the end of the ladder is gone.
Future<void> extractDataToDatabase() async {
  final isar = Repository.isar;

  final String jsonString = await rootBundle.loadString('assets/trivia.json');
  final dynamic decoded = jsonDecode(jsonString);
  if (decoded is! List) {
    throw const FormatException(
      'assets/trivia.json must contain a list of question objects.',
    );
  }

  final parsedQuestions = <Trivia>[];
  for (final entry in decoded) {
    if (entry is! Map<String, dynamic>) continue;
    final trivia = Trivia.tryFromMap(entry);
    if (trivia != null) parsedQuestions.add(trivia);
  }

  if (parsedQuestions.isEmpty) {
    throw const FormatException(
      'assets/trivia.json did not contain any usable questions.',
    );
  }

  // Shuffle once up front so levels are not "all animals, then all geography".
  parsedQuestions.shuffle();

  await isar.writeTxn(() async {
    // Assign each question to a level, then write them in one batch.
    final questions = <Trivia>[
      for (var index = 0; index < parsedQuestions.length; index++)
        parsedQuestions[index].withLevel((index ~/ questionsPerLevel) + 1),
    ];
    await isar.trivias.putAll(questions);

    final levels = <Level>[];
    final levelCount = (parsedQuestions.length / questionsPerLevel).ceil();
    for (var id = 1; id <= levelCount; id++) {
      levels.add(Level(id: id, score: id == 1 ? 0 : null));
    }
    await isar.levels.putAll(levels);

    final categories = Categories.categories;
    for (final category in categories) {
      final numberOfQuestions =
          await isar.trivias
              .filter()
              .categoryEqualTo(category.categoryId)
              .count();
      await isar.categorys.put(
        Category(
          categoryId: category.categoryId,
          name: category.name,
          numberOfQuestions: numberOfQuestions,
          highestScore: 0,
        ),
      );
    }
  });
}
