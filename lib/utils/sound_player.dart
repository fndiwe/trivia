import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays the short feedback clips.
///
/// Every answer used to call `setAsset()` and then `play()`, which re-reads the
/// file from disk on each tap and can lag noticeably behind the tap. All clips
/// are now loaded once and only re-seeked when replayed.
class SoundPlayer {
  SoundPlayer({List<String> assets = defaultAssets}) : _assets = assets;

  /// The clips bundled with the app.
  static const List<String> defaultAssets = [
    'assets/audio/click.mp3',
    'assets/audio/correct.mp3',
    'assets/audio/wrong.mp3',
    'assets/audio/applause.mp3',
    'assets/audio/aww.mp3',
  ];

  static const String click = 'assets/audio/click.mp3';
  static const String correct = 'assets/audio/correct.mp3';
  static const String wrong = 'assets/audio/wrong.mp3';
  static const String applause = 'assets/audio/applause.mp3';
  static const String aww = 'assets/audio/aww.mp3';

  final List<String> _assets;
  final Map<String, AudioPlayer> _players = {};

  /// When disabled, [play] is a no-op (used by the sound setting).
  bool enabled = true;

  bool _disposed = false;

  /// Loads every clip. Failures are swallowed: audio is a nice-to-have and must
  /// never break a round (or a test).
  Future<void> load() async {
    for (final asset in _assets) {
      try {
        final player = AudioPlayer();
        await player.setAsset(asset);
        if (_disposed) {
          await player.dispose();
          return;
        }
        _players[asset] = player;
      } catch (error) {
        debugPrint('SoundPlayer: could not preload $asset ($error)');
      }
    }
  }

  /// Replays [asset] from the start.
  Future<void> play(String asset) async {
    if (!enabled || _disposed) return;
    final player = _players[asset];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (error) {
      debugPrint('SoundPlayer: could not play $asset ($error)');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
