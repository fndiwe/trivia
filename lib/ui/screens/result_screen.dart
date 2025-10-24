import 'dart:math';
import 'package:flutter/material.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/provider/home.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/category.dart';

// Simple confetti burst - local, lightweight implementation so we don't
// add a package dependency. It emits colored circles outward for ~1s.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.duration = const Duration(milliseconds: 900),
  });

  final Duration duration;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<Offset> _targets = [];
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    final rnd = DateTime.now().millisecondsSinceEpoch;
    final random = Random(rnd);
    for (var i = 0; i < 12; i++) {
      final angle = random.nextDouble() * 2 * 3.1415;
      final dist = 60 + random.nextDouble() * 80;
      _targets.add(Offset(cos(angle) * dist, sin(angle) * dist));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_ctrl.value);
          return Stack(
            children: List.generate(_targets.length, (i) {
              final pos = _targets[i] * t;
              final color = _colors[i % _colors.length];
              return Positioned(
                left: 110 + pos.dx,
                top: 110 + pos.dy,
                child: Opacity(
                  opacity: 1.0 - t,
                  child: Container(
                    width: 10.0 * (1.0 - 0.4 * t),
                    height: 10.0 * (1.0 - 0.4 * t),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    this.resultSoundAsset,
    this.levelId,
    this.categoryId,
  });

  final int score;
  final int total;
  final String? resultSoundAsset;
  final int? levelId;
  final String? categoryId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  AudioPlayer? _player;
  bool _unlockedNextLevel = false;
  int? _unlockedLevelId;

  @override
  void initState() {
    super.initState();
    if (widget.resultSoundAsset != null) {
      _player = AudioPlayer();
      // delay playing until after first frame so we can read Providers safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final enabled =
            Provider.of<SettingsProvider>(
              context,
              listen: false,
            ).settings.soundEnabled;
        if (enabled) _playResultSound(widget.resultSoundAsset!);
      });
    }

    // Save score to database (level or category) asynchronously
    _saveScoreToDb();
  }

  Future<void> _saveScoreToDb() async {
    try {
      // capture provider reference synchronously to avoid using BuildContext
      // after async gaps
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final isar = Repository.isar;
      // save level score if provided
      if (widget.levelId != null) {
        final level = await isar.levels.get(widget.levelId!);
        if (level != null) {
          level.score = widget.score;
          await isar.writeTxn(() async {
            await isar.levels.put(level);
          });
          // unlock next level if it exists and is locked (score == null)
          bool nextUnlocked = false;
          try {
            final nextLevelId = widget.levelId! + 1;
            final nextLevel = await isar.levels.get(nextLevelId);
            if (nextLevel != null && nextLevel.score == null) {
              nextLevel.score = 0; // mark as unlocked with 0 score
              await isar.writeTxn(() async {
                await isar.levels.put(nextLevel);
              });
              nextUnlocked = true;
            }
          } catch (_) {
            // ignore unlocking errors
          }
          // update HomeProvider in-memory so Home UI updates immediately
          try {
            homeProvider.updateLevelScore(level.id, level.score);
            if (nextUnlocked) {
              homeProvider.unlockNextLevel(level.id);
              // show animation on result screen
              if (mounted) {
                setState(() {
                  _unlockedNextLevel = true;
                  _unlockedLevelId = level.id + 1;
                });
              }
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _unlockedNextLevel = false;
                    _unlockedLevelId = null;
                  });
                }
              });
            }
          } catch (_) {}
        }
      }

      // save category highest score if provided
      if (widget.categoryId != null) {
        final cats =
            await isar.categorys
                .filter()
                .categoryIdEqualTo(widget.categoryId!)
                .findAll();
        final cat = cats.isNotEmpty ? cats.first : null;
        if (cat != null) {
          if (widget.score > cat.highestScore) {
            cat.highestScore = widget.score;
            await isar.writeTxn(() async {
              await isar.categorys.put(cat);
            });
            // update HomeProvider in-memory so Home UI updates immediately
            try {
              homeProvider.updateCategoryHighest(
                cat.categoryId,
                cat.highestScore,
              );
            } catch (_) {}
          }
        }
      }
      // done
    } catch (_) {
      // ignore DB errors silently for now
    }
  }

  Future<void> _playResultSound(String asset) async {
    try {
      await _player?.setAsset(asset);
      await _player?.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16),
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    minimumSize: const Size(24, 24),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Results',
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // show confetti for excellent performance (perfect score)
                  if (widget.total > 0 &&
                      (widget.score == widget.total ||
                          (((widget.score / widget.total) * 3).round() >= 3)))
                    const ConfettiBurst(),
                  if (widget.total > 0 &&
                      (widget.score == widget.total ||
                          (((widget.score / widget.total) * 3).round() >= 3)))
                    const SizedBox(height: 12),
                  // show unlock animation/banner when next level gets unlocked
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: _unlockedNextLevel ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 350),
                    builder:
                        (context, scale, child) => Transform.scale(
                          scale: scale,
                          child: Opacity(opacity: scale, child: child),
                        ),
                    child:
                        _unlockedNextLevel
                            ? Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.celebration_rounded,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Level ${_unlockedLevelId ?? ''} unlocked!',
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color:
                                          theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.score}',
                            style: theme.textTheme.headlineLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/${widget.total}',
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RatingStars(
                    score: widget.score,
                    numberOfQuestions: widget.total,
                    size: 40,
                    center: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
