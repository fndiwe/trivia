import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';

/// Opens a real, on-disk Isar with all of the app's schemas for integration
/// tests.
///
/// The Isar native library cannot be fetched from inside `flutter test` (the
/// test framework blocks real HTTP), so the binary is expected at
/// `build/isar/libisar.so`. When it is missing the tests are skipped instead
/// of failing, which keeps the suite green on machines without the library.
Future<Isar?> openTestIsar() async {
  final library = File('build/isar/libisar.so');
  if (!library.existsSync()) return null;

  TestWidgetsFlutterBinding.ensureInitialized();
  await Isar.initializeIsarCore(
    libraries: {Abi.current(): library.absolute.path},
  );
  final directory = Directory.systemTemp.createTempSync('trivia_it');
  final isar = await Isar.open(Repository.schemas, directory: directory.path);
  Repository.isar = isar;
  return isar;
}

/// Seeds a small, deterministic question bank: 30 sports questions in level 1
/// and 25 history questions in level 2.
Future<void> seedTestBank(Isar isar) async {
  final questions = <Trivia>[
    for (var i = 0; i < 30; i++)
      Trivia(
        question: 'Sports question $i?',
        answer: 'Answer $i',
        choices: ['Answer $i', 'Wrong $i'],
        category: 'sports',
        level: 1,
      ),
    for (var i = 0; i < 25; i++)
      Trivia(
        question: 'History question $i?',
        answer: 'Answer $i',
        choices: ['Answer $i', 'Wrong $i'],
        category: 'history',
        level: 2,
      ),
  ];

  await isar.writeTxn(() async {
    await isar.trivias.putAll(questions);
    await isar.levels.putAll([Level(id: 1, score: 0), Level(id: 2)]);
    await isar.categorys.put(
      Category(categoryId: 'sports', name: 'Sports', numberOfQuestions: 30),
    );
    await isar.categorys.put(
      Category(categoryId: 'history', name: 'History', numberOfQuestions: 25),
    );
    await isar.settings.put(Settings());
  });
}
