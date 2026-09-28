import 'package:isar/isar.dart';

part 'level.g.dart';

/// One level of the campaign. `score == null` means "still locked"; a non-null
/// score (including 0) means the level has been unlocked.
@collection
class Level {
  final Id id;
  int? score;

  Level({required this.id, this.score});

  bool get isUnlocked => score != null || id == 1;

  Level changeScore(int score) => this..score = score;
}
