import 'package:isar/isar.dart';
import 'package:trivia/utils/scoring.dart';

part 'round_result.g.dart';

/// Which flavour of round was played.
///
/// The stored value is the enum's index, so **only ever append** new values:
/// reordering existing ones would reinterpret saved rows.
enum RoundMode {
  /// A campaign level.
  level,

  /// Free play in one category.
  category,

  /// The once-a-day challenge.
  daily,

  /// Practising questions that were answered wrongly before.
  practice,
}

/// One completed round, kept so the app can show history and statistics.
@collection
class RoundResult {
  Id id = Isar.autoIncrement;

  /// Indexed so the statistics screen can page through history newest-first.
  @Index()
  final DateTime playedAt;

  @enumerated
  final RoundMode mode;

  final String? categoryId;
  final int? levelId;
  final int score;
  final int total;

  RoundResult({
    required this.playedAt,
    required this.mode,
    required this.score,
    required this.total,
    this.categoryId,
    this.levelId,
  });

  @ignore
  int get stars => starsFor(score, total);

  @ignore
  double get accuracy => total == 0 ? 0 : score / total;
}
