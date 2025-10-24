import 'package:isar/isar.dart';

part 'level.g.dart';

@collection
class Level {
  final Id id;
  int? score;

  Level({required this.id, this.score});

  Level changeScore(int score) => this..score = score;
}