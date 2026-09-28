import 'package:flutter/material.dart';

/// The row of round controls: the three lifelines plus pause.
class GameControlsBar extends StatelessWidget {
  const GameControlsBar({
    super.key,
    required this.enabled,
    required this.fiftyFiftyUsed,
    required this.skipUsed,
    required this.extraTimeUsed,
    required this.timerEnabled,
    required this.paused,
    required this.onFiftyFifty,
    required this.onSkip,
    required this.onExtraTime,
    required this.onTogglePause,
  });

  /// False once the question has been resolved or while an overlay is open.
  final bool enabled;

  final bool fiftyFiftyUsed;
  final bool skipUsed;
  final bool extraTimeUsed;

  /// Hides the "+seconds" lifeline when the round runs without a countdown.
  final bool timerEnabled;

  final bool paused;

  final VoidCallback onFiftyFifty;
  final VoidCallback onSkip;
  final VoidCallback onExtraTime;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LifelineButton(
          icon: Icons.filter_2_outlined,
          tooltip:
              fiftyFiftyUsed
                  ? '50:50 already used'
                  : '50:50 - remove two wrong answers',
          used: fiftyFiftyUsed,
          onPressed: enabled && !fiftyFiftyUsed ? onFiftyFifty : null,
        ),
        const SizedBox(width: 8),
        _LifelineButton(
          icon: Icons.skip_next_outlined,
          tooltip: skipUsed ? 'Skip already used' : 'Skip this question',
          used: skipUsed,
          onPressed: enabled && !skipUsed ? onSkip : null,
        ),
        const SizedBox(width: 8),
        if (timerEnabled)
          _LifelineButton(
            icon: Icons.more_time_outlined,
            tooltip: extraTimeUsed ? 'Extra time already used' : '+10 seconds',
            used: extraTimeUsed,
            onPressed: enabled && !extraTimeUsed ? onExtraTime : null,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'No timer',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(width: 24),
        IconButton.filledTonal(
          tooltip: paused ? 'Resume' : 'Pause',
          onPressed: onTogglePause,
          icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
        ),
      ],
    );
  }
}

class _LifelineButton extends StatelessWidget {
  const _LifelineButton({
    required this.icon,
    required this.tooltip,
    required this.used,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool used;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor:
            used
                ? Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : null,
      ),
    );
  }
}

/// Overlay shown while the round is paused. It hides the question so pausing
/// cannot be used to buy thinking time.
class PausedOverlay extends StatelessWidget {
  const PausedOverlay({
    super.key,
    required this.onResume,
    required this.onExit,
  });

  final VoidCallback onResume;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_outline,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Paused', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Your progress in this round is kept.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onExit, child: const Text('Quit round')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Number of seconds added by the "+time" lifeline.
const int extraTimeSeconds = 10;
