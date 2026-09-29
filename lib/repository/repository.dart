import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/models/settings.dart';
import 'package:trivia/models/trivia.dart';

/// Thin wrapper around the single Isar instance used by the app.
///
/// This used to be `static Isar isar = Isar.getInstance()!`, so touching it
/// before `Isar.open` blew up with an opaque null-check error. It now throws an
/// actionable [StateError] instead, and [init] is the single place that knows
/// which schemas the app needs.
class Repository {
  Repository._();

  /// Every schema the app persists. Public so tests can open the same set.
  static const List<CollectionSchema<dynamic>> schemas = [
    TriviaSchema,
    LevelSchema,
    CategorySchema,
    SettingsSchema,
    QuestionStatSchema,
    RoundResultSchema,
  ];

  static Isar? _isar;

  static Isar get isar {
    final instance = _isar ?? Isar.getInstance();
    if (instance == null) {
      throw StateError(
        'Isar has not been opened yet. Call `Repository.init(directory: ...)` '
        'before reading or writing data.',
      );
    }
    return instance;
  }

  static set isar(Isar instance) => _isar = instance;

  /// Opens every schema the app uses and exposes the instance through
  /// [Repository.isar].
  static Future<Isar> init({required String directory}) async {
    final instance = await Isar.open(schemas, directory: directory);
    _isar = instance;
    return instance;
  }
}
