import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trivia/l10n/category_names.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/question_stat.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/repository/stats_repository.dart';
import 'package:trivia/utils/categories.dart';
import 'package:trivia/utils/routes.dart';
import 'package:trivia/l10n/l10n.dart';

/// Everything the app has recorded about the player's play.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  PlayerStats? _stats;
  List<RoundResult> _recentRounds = const <RoundResult>[];
  List<CategoryStats> _byCategory = const <CategoryStats>[];
  List<QuestionStat> _hardest = const <QuestionStat>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await StatsRepository.load();
    final rounds = await StatsRepository.recentRounds();
    final byCategory = await StatsRepository.byCategory();
    final hardest = await StatsRepository.hardestQuestions();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _recentRounds = rounds;
      _byCategory = byCategory;
      _hardest = hardest;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _stats;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.statsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (stats == null || stats.roundsPlayed == 0)
                      const _EmptyStats()
                    else ...[
                      _StatGrid(stats: stats),
                      if (_byCategory.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.byCategory,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final category in _byCategory)
                          _CategoryStatTile(stats: category),
                      ],
                      if (_hardest.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.hardestQuestions,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final question in _hardest)
                          _HardestQuestionTile(question: question),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.recentRounds,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final round in _recentRounds)
                        _RoundTile(round: round),
                    ],
                  ],
                ),
              ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final percent = (stats.accuracy * 100).round();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.sports_score_outlined,
                label: context.l10n.statAccuracy,
                value: '$percent%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.play_circle_outline,
                label: context.l10n.statRounds,
                value: '${stats.roundsPlayed}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_outlined,
                label: context.l10n.statBestRound,
                value: '${stats.bestRound}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.help_outline,
                label: context.l10n.statQuestionsSeen,
                value: '${stats.questionsSeen}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.workspace_premium_outlined,
                label: context.l10n.statMastered,
                value: '${stats.masteredQuestions}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.school_outlined,
                label: context.l10n.statToPractise,
                value: '${stats.questionsToPractise}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  const _RoundTile({required this.round});

  final RoundResult round;

  static const Map<RoundMode, IconData> _modeIcons = {
    RoundMode.level: Icons.flag_outlined,
    RoundMode.category: Icons.category_outlined,
    RoundMode.daily: Icons.wb_sunny_outlined,
    RoundMode.practice: Icons.school_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playedAt = round.playedAt;
    final date =
        '${playedAt.day.toString().padLeft(2, '0')}/'
        '${playedAt.month.toString().padLeft(2, '0')}/'
        '${playedAt.year}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _modeIcons[round.mode] ?? Icons.help_outline,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        round.levelId != null
            ? context.l10n.levelLabel(round.levelId!)
            : _modeLabel(context, round.mode),
      ),
      subtitle: Text(date),
      trailing: Text(
        '${round.score}/${round.total}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(context.l10n.noRoundsYet, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            context.l10n.noRoundsHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Localised label for a [RoundMode].
String _modeLabel(BuildContext context, RoundMode mode) => switch (mode) {
  RoundMode.level => context.l10n.modeLevel,
  RoundMode.category => context.l10n.modeCategory,
  RoundMode.daily => context.l10n.modeDaily,
  RoundMode.practice => context.l10n.modePractice,
};

/// One category row in the \"By category\" section. Tapping it starts a round
/// in that category, because the worst row is usually the one worth playing.
class _CategoryStatTile extends StatelessWidget {
  const _CategoryStatTile({required this.stats});

  final CategoryStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (stats.accuracy * 100).round();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        context.l10n.categoryLabel(stats.categoryId),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: stats.accuracy,
            minHeight: 6,
            color: _accuracyColor(theme, stats.accuracy),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$percent%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _accuracyColor(theme, stats.accuracy),
            ),
          ),
          Text(
            '${stats.correct}/${stats.answered}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () {
        final category = _findCategory(stats.categoryId);
        if (category == null) return;
        Navigator.of(
          context,
        ).pushNamed(Routes.gameplay, arguments: QuizRequest.category(category));
      },
    );
  }

  static Category? _findCategory(String categoryId) {
    for (final category in Categories.categories) {
      if (category.categoryId == categoryId) return category;
    }
    return null;
  }

  static Color _accuracyColor(ThemeData theme, double accuracy) {
    if (accuracy >= 0.8) return Colors.green.shade600;
    if (accuracy >= 0.5) return Colors.orange.shade700;
    return theme.colorScheme.error;
  }
}

/// One question row in the \"hardest questions\" section.
class _HardestQuestionTile extends StatelessWidget {
  const _HardestQuestionTile({required this.question});

  final QuestionStat question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (question.accuracy * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.category.isEmpty
                        ? ''
                        : context.l10n.categoryLabel(question.category),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  context.l10n.accuracyOf(
                    percent,
                    question.timesCorrect,
                    question.timesShown,
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
