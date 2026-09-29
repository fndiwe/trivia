import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/l10n/category_names.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.current,
    required this.total,
    required this.score,
    this.category,
    this.level,
    this.modeLabel,
    required this.onExit,
  });

  final int current;
  final int total;
  final int score;
  final Category? category;
  final Level? level;

  /// Shown instead of the level number for modes that have no level, e.g. the
  /// daily challenge and the practice mode.
  final String? modeLabel;

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onExit,
          icon: const Icon(Icons.close_rounded),
          color: Colors.red,
        ),
        Text(
          context.l10n.questionCounter(current, total),
          style: theme.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.scoreLabel(score),
          style: theme.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        RatingStars(score: score, numberOfQuestions: total),
        if (category != null)
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/${category!.categoryId}.svg',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 5),
              Text(
                context.l10n.categoryLabel(category!.categoryId),
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            level != null
                ? context.l10n.levelLabel(level!.id)
                : (modeLabel ?? ''),
            style: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
