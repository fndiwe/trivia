import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.score,
    required this.numberOfQuestions,
    this.size = 24.0,
    this.center = false,
  });

  final int score;
  final int numberOfQuestions;
  final double size;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final numberOfStars = ((score / numberOfQuestions) * 3).round();

    final List<Widget> coloredStars = List.generate(
      numberOfStars,
      (value) => Icon(
        Icons.star_rate_rounded,
        color: theme.colorScheme.primary,
        size: size,
      ),
    );
    final List<Widget> nonColoredStars = List.generate(
      3 - numberOfStars,
      (value) => Icon(
        Icons.star_rate_rounded,
        color: theme.colorScheme.primaryContainer,
        size: size,
      ),
    );

    return Row(
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [...coloredStars, ...nonColoredStars],
    );
  }
}
