import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.current,
    required this.total,
    required this.score,
    this.category,
    this.level,
    required this.onExit,
  });

  final int current;
  final int total;
  final int score;
  final Category? category;
  final Level? level;
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
          'Q: $current/$total',
          style: theme.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Score: $score',
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
                category!.name,
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            'Level ${level?.id}',
            style: theme.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
