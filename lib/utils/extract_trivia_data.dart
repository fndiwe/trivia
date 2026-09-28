import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show compute;
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

/// How many questions are written per transaction while importing.
const int _importBatchSize = 500;

/// Decodes and validates the bundled question bank.
///
/// Top-level so it can be handed to [compute] and run on a background isolate:
/// parsing a 6 MB JSON array on the UI isolate is what made the first launch
/// feel stuck behind the splash screen.
///
/// Malformed records are skipped rather than aborting the whole import, and the
/// result is shuffled once so levels are not "all animals, then all history".
List<Trivia> parseQuestionBank(String json) {
  final dynamic decoded = jsonDecode(json);
  if (decoded is! List) {
    throw const FormatException(
      'assets/trivia.json must contain a list of question objects.',
    );
  }

  final questions = <Trivia>[];
  for (final entry in decoded) {
    if (entry is Map<String, dynamic>) {
      final trivia = Trivia.tryFromMap(entry);
      if (trivia != null) questions.add(trivia);
    }
  }

  if (questions.isEmpty) {
    throw const FormatException(
      'assets/trivia.json did not contain any usable questions.',
    );
  }

  questions.shuffle(Random(questions.length));
  return questions;
}

/// Progress of [importQuestionBank]: `done` of `total` questions written.
typedef ImportProgress = void Function(int done, int total);

/// Loads the bundled question bank into Isar and returns how many questions
/// were imported.
///
/// Parsing happens on a background isolate; writing happens in batches so the
/// splash screen can show real progress instead of an indeterminate spinner.
Future<int> importQuestionBank({ImportProgress? onProgress}) async {
  final isar = Repository.isar;

  final String jsonString = await rootBundle.loadString('assets/trivia.json');
  final questions = await compute(parseQuestionBank, jsonString);
  final total = questions.length;

  // Questions first, in batches.
  for (var start = 0; start < total; start += _importBatchSize) {
    final end = (start + _importBatchSize).clamp(0, total);
    final batch = <Trivia>[
      for (var index = start; index < end; index++)
        questions[index].withLevel((index ~/ questionsPerLevel) + 1),
    ];
    await isar.writeTxn(() async {
      await isar.trivias.putAll(batch);
    });
    onProgress?.call(end, total);
  }

  // Level ladder: level 1 is unlocked from the start.
  final levelCount = (total / questionsPerLevel).ceil();
  await isar.writeTxn(() async {
    await isar.levels.putAll([
      for (var id = 1; id <= levelCount; id++)
        Level(id: id, score: id == 1 ? 0 : null),
    ]);

    for (final category in Categories.categories) {
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

  return total;
}
