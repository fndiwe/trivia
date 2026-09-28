import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/ui/widgets/pentagon.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';
import 'package:trivia/l10n/l10n.dart';

/// Pentagon tile for one campaign level.
///
/// * Locked levels show a padlock instead of three empty stars (they cannot be
///   played, so showing a 0/3 rating was misleading).
/// * The star rating is scaled to [questionsPerLevel] instead of a hard-coded
///   `10`.
/// * The unlock animation no longer rebuilds `Transform.scale` on every tick of
///   the whole subtree.
class LevelCard extends StatefulWidget {
  const LevelCard({super.key, required this.level, required this.onPress});

  final Level level;
  final VoidCallback onPress;

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  bool _wasUnlocked = false;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _wasUnlocked = widget.level.isUnlocked;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowUnlocked = widget.level.isUnlocked;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!_wasUnlocked && nowUnlocked && !reduceMotion) {
      // Just unlocked -> play the highlight animation once, then settle back.
      _animCtrl.forward(from: 0.0).then((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          _animCtrl.reverse();
        });
      });
    }
    _wasUnlocked = nowUnlocked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = widget.level.isUnlocked;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        if (unlocked)
          Positioned(
            top: -23,
            child: RatingStars(
              score: widget.level.score ?? 0,
              numberOfQuestions: questionsPerLevel,
            ),
          ),
        Semantics(
          button: true,
          enabled: unlocked,
          label:
              unlocked
                  ? context.l10n.levelSemantics(widget.level.id)
                  : context.l10n.levelLockedSemantics(widget.level.id),
          child: GestureDetector(
            onTap: unlocked ? widget.onPress : null,
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder:
                  (context, child) => Transform.scale(
                    scale: 1.0 + (_animCtrl.value * 0.08),
                    child: child,
                  ),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: RoundedPentagonPainter(
                      fillColor: theme.colorScheme.primary.withValues(
                        alpha: unlocked ? 1 : 0.4,
                      ),
                      cornerRadius: 10,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!unlocked) ...[
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        context.l10n.levelWord,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        NumberFormat().format(widget.level.id).padLeft(2, '0'),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
