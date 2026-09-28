import 'package:flutter/material.dart';
import 'package:trivia/models/answered_question.dart';
import 'package:trivia/utils/theme.dart';

/// One row of the post-round answer review.
///
/// Shows the question, what the player picked (or why they did not pick
/// anything) and the correct answer.
class AnsweredQuestionTile extends StatelessWidget {
  const AnsweredQuestionTile({
    super.key,
    required this.answer,
    required this.index,
  });

  final AnsweredQuestion answer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final correct = answer.trivia.answer;

    final (IconData icon, Color iconColor, String verdict) = switch (answer) {
      AnsweredQuestion(isCorrect: true) => (
        Icons.check_circle_rounded,
        AppColors.correctFor(theme),
        'Correct',
      ),
      AnsweredQuestion(timedOut: true) => (
        Icons.timer_off_outlined,
        scheme.error,
        'Out of time',
      ),
      AnsweredQuestion(wasSkipped: true) => (
        Icons.skip_next_outlined,
        scheme.onSurfaceVariant,
        'Skipped',
      ),
      _ => (Icons.cancel_rounded, scheme.error, 'Wrong'),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Q${index + 1}. ${answer.trivia.question}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              verdict,
              style: theme.textTheme.labelMedium?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (answer.wasAnswered && !answer.isCorrect) ...[
              const SizedBox(height: 6),
              _Line(
                label: 'You answered',
                value: answer.selectedChoice!,
                color: scheme.error,
              ),
            ],
            const SizedBox(height: 6),
            _Line(
              label: 'Answer',
              value: correct,
              color: AppColors.correctFor(theme),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
