import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_outcome.dart';
import 'package:trivia/models/round_summary.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/progress_repository.dart';
import 'package:trivia/ui/screens/gameplay.dart';
import 'package:trivia/ui/widgets/answered_question_tile.dart';
import 'package:trivia/ui/widgets/confetti_burst.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';
import 'package:trivia/utils/sound_player.dart';
import 'package:trivia/l10n/l10n.dart';

/// End of a round: what was scored, what changed, and a review of every
/// question so the player can learn from it.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.outcome});

  final RoundOutcome outcome;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final SoundPlayer _sounds;

  RoundSummary? _summary;
  bool _saveFailed = false;

  RoundOutcome get _outcome => widget.outcome;

  @override
  void initState() {
    super.initState();
    final asset = resultSoundAsset(_outcome.score, _outcome.total);
    _sounds = SoundPlayer(assets: [asset]);
    unawaited(_start());
  }

  @override
  void dispose() {
    unawaited(_sounds.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    final soundEnabled = context.read<SettingsProvider>().settings.soundEnabled;
    if (soundEnabled) {
      unawaited(
        _sounds.load().then(
          (_) => _sounds.play(resultSoundAsset(_outcome.score, _outcome.total)),
        ),
      );
    }
    await _persist();
  }

  /// Writes the round through [ProgressRepository] and refreshes the providers
  /// so the home screen shows the new scores straight away.
  Future<void> _persist() async {
    try {
      final summary = await ProgressRepository.saveRound(
        mode: _outcome.request.mode,
        score: _outcome.score,
        total: _outcome.total,
        levelId: _outcome.request.level?.id,
        categoryId: _outcome.request.category?.categoryId,
      );
      if (!mounted) return;
      await context.read<SettingsProvider>().refresh();
      if (!mounted) return;
      await context.read<HomeProvider>().loadAll();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saveFailed = true);
    }
  }

  Future<void> _playAgain() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GamePlayScreen(request: _outcome.request),
      ),
    );
  }

  Future<void> _practiseMistakes() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const GamePlayScreen(request: QuizRequest.practice()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = starsFor(_outcome.score, _outcome.total);
    // Respect the OS "reduce motion" setting: no confetti animation for those
    // who asked for fewer animations.
    final showConfetti =
        _outcome.total > 0 &&
        stars >= maxStars &&
        !MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12),
                  child: IconButton.filled(
                    tooltip: context.l10n.backToHome,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      minimumSize: const Size(24, 24),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    Center(
                      child: Text(
                        context.l10n.resultsTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (showConfetti) ...[
                      const Center(child: ConfettiBurst()),
                      const SizedBox(height: 8),
                    ],
                    ..._badges(theme),
                    if (_saveFailed)
                      _Badge(
                        icon: Icons.cloud_off_outlined,
                        label: context.l10n.couldNotSave,
                      ),
                    Center(
                      child: _ScoreRing(
                        score: _outcome.score,
                        total: _outcome.total,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RatingStars(
                      score: _outcome.score,
                      numberOfQuestions: _outcome.total,
                      size: 40,
                      center: true,
                    ),
                    const SizedBox(height: 20),
                    _ActionButtons(
                      onPlayAgain: _playAgain,
                      onHome: () => Navigator.of(context).pop(),
                      onPractise:
                          _summary != null &&
                                  _summary!.practiceQuestionCount > 0
                              ? _practiseMistakes
                              : null,
                      practiceCount: _summary?.practiceQuestionCount ?? 0,
                    ),
                    const SizedBox(height: 24),
                    _ReviewHeader(
                      total: _outcome.total,
                      correct: _outcome.correctCount,
                      mistakes: _outcome.mistakes.length,
                    ),
                    const SizedBox(height: 8),
                    for (final (index, answer) in _outcome.answers.indexed)
                      AnsweredQuestionTile(answer: answer, index: index),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _badges(ThemeData theme) {
    final summary = _summary;
    if (summary == null) return const <Widget>[];

    final badges = <Widget>[];
    if (summary.unlockedLevelId != null) {
      badges.add(
        _Badge(
          icon: Icons.celebration_rounded,
          label: context.l10n.levelUnlocked(summary.unlockedLevelId!),
        ),
      );
    }
    if (summary.newCategoryBest) {
      badges.add(
        _Badge(
          icon: Icons.emoji_events_outlined,
          label: context.l10n.newBestScore,
        ),
      );
    }
    if (summary.streak > 0) {
      badges.add(
        _Badge(
          icon: Icons.local_fire_department_outlined,
          label:
              summary.streakIncreased
                  ? context.l10n.streakBadgeNew(summary.streak)
                  : context.l10n.streakBadge(summary.streak),
        ),
      );
    }
    if (badges.isEmpty) return const <Widget>[];
    return [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: badges,
      ),
      const SizedBox(height: 16),
    ];
  }
}

/// Circular score badge in the middle of the results screen.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: const [
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
              '$score',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/$total',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small capsule used for the unlock / best score / streak badges.
class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onPlayAgain,
    required this.onHome,
    required this.practiceCount,
    this.onPractise,
  });

  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback? onPractise;
  final int practiceCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onPlayAgain,
              icon: const Icon(Icons.replay_rounded),
              label: Text(context.l10n.playAgain),
            ),
            FilledButton.tonalIcon(
              onPressed: onHome,
              icon: const Icon(Icons.home_outlined),
              label: Text(context.l10n.home),
            ),
          ],
        ),
        if (onPractise != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onPractise,
            icon: const Icon(Icons.school_outlined),
            label: Text(context.l10n.practiseTheseMistakes(practiceCount)),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.total,
    required this.correct,
    required this.mistakes,
  });

  final int total;
  final int correct;
  final int mistakes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.review,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          mistakes == 0
              ? context.l10n.allCorrect(total)
              : context.l10n.correctOfTotal(correct, total),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
