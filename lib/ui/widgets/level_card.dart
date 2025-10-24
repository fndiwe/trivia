import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/ui/widgets/pentagon.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';

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
    _wasUnlocked = widget.level.score != null || widget.level.id == 1;
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
    final nowUnlocked = widget.level.score != null || widget.level.id == 1;
    if (!_wasUnlocked && nowUnlocked) {
      // just unlocked -> play highlight animation once, then return to normal
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
    final unlocked = widget.level.score != null || widget.level.id == 1;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -23,
          child: RatingStars(
            score: widget.level.score ?? 0,
            numberOfQuestions: 10,
          ),
        ),
        GestureDetector(
          onTap: unlocked ? widget.onPress : null,
          child: AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) {
              final scale = 1.0 + (_animCtrl.value * 0.08);
              return Transform.scale(
                scale: scale,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: RoundedPentagonPainter(
                        fillColor: theme.colorScheme.primary.withValues(
                          alpha: unlocked ? 1 : .4,
                        ),
                        cornerRadius: 10,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Level",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          NumberFormat()
                              .format(widget.level.id)
                              .padLeft(2, '0'),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
