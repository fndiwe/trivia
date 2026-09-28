import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/repository/stats_repository.dart';

/// Everything the app has recorded about the player's play.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  PlayerStats? _stats;
  List<RoundResult> _recentRounds = const <RoundResult>[];
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
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _recentRounds = rounds;
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
          'Statistics',
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
                      const SizedBox(height: 24),
                      Text(
                        'Recent rounds',
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
                label: 'Accuracy',
                value: '$percent%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.play_circle_outline,
                label: 'Rounds',
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
                label: 'Best round',
                value: '${stats.bestRound}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.help_outline,
                label: 'Questions seen',
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
                label: 'Mastered',
                value: '${stats.masteredQuestions}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.school_outlined,
                label: 'To practise',
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
        round.levelId != null ? 'Level ${round.levelId}' : round.mode.name,
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
          Text('No rounds played yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Finish a level or a category round and your accuracy, best score '
            'and hardest questions will show up here.',
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
