import 'dart:math';

/// Randomly picks [count] items out of [pool].
///
/// Pure and deterministic when a seeded [Random] is supplied, which makes the
/// selection rules unit testable. Returns a copy so callers never mutate the
/// pool they passed in.
List<T> pickRandom<T>(List<T> pool, int count, {Random? random}) {
  if (count <= 0 || pool.isEmpty) return <T>[];
  final shuffled = List<T>.of(pool)..shuffle(random ?? Random());
  if (shuffled.length <= count) return shuffled;
  return shuffled.take(count).toList();
}
