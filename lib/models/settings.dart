import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:trivia/utils/scoring.dart';

part 'settings.g.dart';

/// User preferences. Persisted as a single row with a fixed id.
@collection
class Settings {
  Id id = 1;

  @enumerated
  ThemeMode theme = ThemeMode.system;

  bool soundEnabled = true;

  bool hapticsEnabled = true;

  /// How many questions a single category round contains. Campaign levels are
  /// always [questionsPerLevel] long.
  int categoryRoundSize = defaultCategoryRoundSize;

  /// Seconds allowed per question. `0` disables the countdown entirely, which
  /// turns the game into a relaxed practice mode.
  int secondsPerQuestion = defaultSecondsPerQuestion;

  /// Version of the question bank that was imported into Isar. Compared against
  /// [currentQuestionBankVersion] on start-up so a new bundled
  /// `assets/trivia.json` is imported instead of silently ignored.
  int questionBankVersion = 0;

  Settings({
    this.id = 1,
    this.theme = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.categoryRoundSize = defaultCategoryRoundSize,
    this.secondsPerQuestion = defaultSecondsPerQuestion,
    this.questionBankVersion = 0,
  });

  Settings copyWith({
    ThemeMode? theme,
    bool? soundEnabled,
    bool? hapticsEnabled,
    int? categoryRoundSize,
    int? secondsPerQuestion,
    int? questionBankVersion,
  }) => Settings(
    id: id,
    theme: theme ?? this.theme,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    categoryRoundSize: categoryRoundSize ?? this.categoryRoundSize,
    secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
    questionBankVersion: questionBankVersion ?? this.questionBankVersion,
  );
}
