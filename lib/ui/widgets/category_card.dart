import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onPress,
    this.roundSize = defaultCategoryRoundSize,
  });

  final Category category;

  /// Number of questions a round in this category will contain. Used as the
  /// denominator for the star rating so the stars match what the player can
  /// actually achieve.
  final int roundSize;

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionsPerRound = roundSize < 1 ? 1 : roundSize;

    return Semantics(
      button: true,
      label: '${category.name}, ${category.numberOfQuestions} questions',
      child: GestureDetector(
        onTap: onPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 2,
              shadowColor: theme.colorScheme.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${NumberFormat().format(category.numberOfQuestions)} questions',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Best: ${category.highestScore}/$questionsPerRound',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    RatingStars(
                      score: category.highestScore,
                      numberOfQuestions: questionsPerRound,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -18,
              left: 12,
              child: SvgPicture.asset(
                'assets/images/${category.categoryId}.svg',
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

