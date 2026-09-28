import 'package:flutter/material.dart';
import 'package:trivia/utils/scoring.dart';
import 'package:trivia/l10n/l10n.dart';

/// Three-star rating for a score out of [numberOfQuestions].
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
    // Guarded inside starsFor: a round with no questions used to divide by zero
    // here and throw while the question list was still loading.
    final earned = starsFor(score, numberOfQuestions);

    return Semantics(
      label: context.l10n.starRatingSemantics(earned, maxStars),
      child: Row(
        mainAxisAlignment:
            center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          for (var i = 0; i < maxStars; i++)
            Icon(
              Icons.star_rate_rounded,
              color:
                  i < earned
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
              size: size,
            ),
        ],
      ),
    );
  }
}
