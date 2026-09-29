/// Difficulty estimation for questions.
///
/// Two kinds of estimate live here:
///
/// * [estimateDifficulty] is *intrinsic*: it only looks at the question and
///   its choices, so it works for a brand new install with no history. It is
///   what orders the campaign on first import.
/// * [posteriorDifficulty] blends the intrinsic estimate with what the player
///   has actually answered, so the campaign can re-rank itself with data.
///
/// Both return `0..1` (higher = harder). Kept pure so the rules are unit
/// testable without Flutter or Isar.
library;

/// Normalised edit-distance similarity in `[0, 1]`.
///
/// `1` means the two strings are identical (ignoring case), `0` means they
/// share nothing. Used to measure how easy the wrong choices are to confuse
/// with the answer.
double similarity(String a, String b) {
  if (a.isEmpty || b.isEmpty) return a == b ? 1.0 : 0.0;
  final lowerA = a.toLowerCase();
  final lowerB = b.toLowerCase();
  if (lowerA == lowerB) return 1.0;
  final distance = editDistance(lowerA, lowerB);
  final longest = a.length > b.length ? a.length : b.length;
  return 1.0 - (distance / longest);
}

/// Classic Levenshtein distance, O(n*m) time and O(m) space.
int editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (index) => index);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = _min3(
        current[j - 1] + 1,
        previous[j] + 1,
        previous[j - 1] + cost,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

int _min3(int a, int b, int c) {
  final ab = a < b ? a : b;
  return ab < c ? ab : c;
}

/// Intrinsic difficulty of a question in `[0, 1]`, higher = harder.
///
/// The three signals are deliberately simple and language-agnostic:
///
/// * *Question length* - longer questions take more reading and tend to hide
///   the actual ask (30% of the score).
/// * *Distractor similarity* - the closest wrong choice to the answer. Similar
///   choices are easy to confuse and hard to eliminate (50%).
/// * *Numeric answer* - recalling a number is harder than recognising a name
///   you can reason about by association (20%).
double estimateDifficulty({
  required String question,
  required String answer,
  required List<String> choices,
}) {
  final lengthScore = _clamp01((question.length - 30) / 170);

  var bestDistractorSimilarity = 0.0;
  for (final choice in choices) {
    if (choice == answer) continue;
    final score = similarity(answer, choice);
    if (score > bestDistractorSimilarity) {
      bestDistractorSimilarity = score;
    }
  }

  final numericScore = isNumericAnswer(answer) ? 1.0 : 0.0;

  return _clamp01(
    (0.30 * lengthScore) +
        (0.50 * bestDistractorSimilarity) +
        (0.20 * numericScore),
  );
}

/// Whether [text] reads as a number (allowing thousand separators, decimals
/// and common units/currency symbols).
bool isNumericAnswer(String text) {
  final cleaned = text.replaceAll(RegExp(r'[\s,\.,%\u20ac\u00a3$]'), '');
  if (cleaned.isEmpty) return false;
  return RegExp(r'^-?\d+(\.\d+)?$').hasMatch(cleaned);
}

/// Blends the intrinsic estimate with observed performance.
///
/// With no answers the result is exactly [intrinsic]. As answers accumulate,
/// the result moves toward the observed difficulty (`1 - accuracy`), with a
/// Beta(1, 1) prior smoothing the accuracy. [alpha] is roughly how many
/// answers it takes for the empirical estimate to dominate the intrinsic one.
double posteriorDifficulty({
  required int correct,
  required int shown,
  required double intrinsic,
  int alpha = 8,
}) {
  if (shown <= 0) return intrinsic;
  final observedAccuracy = (correct + 1) / (shown + 2);
  final observedDifficulty = 1 - observedAccuracy;
  final empiricalWeight = shown / (shown + alpha);
  final blended =
      ((1 - empiricalWeight) * intrinsic) +
      (empiricalWeight * observedDifficulty);
  return _clamp01(blended);
}

double _clamp01(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);
