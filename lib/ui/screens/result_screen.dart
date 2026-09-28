import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/ui/widgets/confetti_burst.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';

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
        if (cat != null && cat.recordScore(widget.score)) {
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
    final earnedStars = starsFor(widget.score, widget.total);
    final isPerfect = widget.total > 0 && earnedStars >= maxStars;

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
                  // celebrate an excellent performance (three stars)
                  if (isPerfect) ...[
                    const ConfettiBurst(),
                    const SizedBox(height: 12),
                  ],
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
