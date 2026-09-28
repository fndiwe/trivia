import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/scoring.dart';

void main() {
  group('starsFor', () {
    test('returns 0 for an empty round instead of throwing', () {
      // Guards the regression where `(score / 0).round()` threw while the
      // question list was still loading.
      expect(starsFor(0, 0), 0);
    });

    test('awards one star for a third of the answers', () {
      expect(starsFor(3, 9), 1);
    });

    test('awards three stars for a perfect round', () {
      expect(starsFor(10, 10), 3);
      expect(starsFor(20, 20), 3);
    });

    test('rounds the ratio to the nearest star', () {
      expect(starsFor(6, 10), 2);
      expect(starsFor(5, 10), 2);
      expect(starsFor(4, 10), 1);
    });

    test('never exceeds maxStars when the score is out of range', () {
      expect(starsFor(50, 10), 3);
    });

    test('never goes below zero', () {
      expect(starsFor(-5, 10), 0);
    });
  });

  group('resultSoundAsset', () {
    test('plays applause from two stars up', () {
      expect(resultSoundAsset(10, 10), 'assets/audio/applause.mp3');
      expect(resultSoundAsset(7, 10), 'assets/audio/applause.mp3');
    });

    test('plays the softer sound for a weak round', () {
      expect(resultSoundAsset(2, 10), 'assets/audio/aww.mp3');
      expect(resultSoundAsset(0, 10), 'assets/audio/aww.mp3');
    });
  });

  group('roundSize', () {
    test('caps at the available questions', () {
      expect(roundSize(requested: 20, available: 8), 8);
    });

    test('uses the request when enough questions exist', () {
      expect(roundSize(requested: 20, available: 100), 20);
    });

    test('returns 0 when nothing is available', () {
      expect(roundSize(requested: 20, available: 0), 0);
    });
  });
}
