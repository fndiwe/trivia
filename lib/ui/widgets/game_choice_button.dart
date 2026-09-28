import 'package:flutter/material.dart';
import 'package:trivia/utils/theme.dart';

/// Visual state of an answer button.
///
/// The gameplay screen used to infer this from raw colours (comparing the
/// background colour against `theme.colorScheme.onSurface` to guess whether a
/// button was "still default"), which was brittle: it broke as soon as the
/// theme changed. The state is now explicit.
enum ChoiceStatus {
  /// Not answered yet.
  idle,

  /// The correct answer, revealed once the player answers or time runs out.
  correct,

  /// The answer the player picked, when it was wrong.
  wrong,

  /// Neither picked nor correct, dimmed after the answer is revealed.
  muted,

  /// Removed from play by the 50:50 lifeline. Struck out and not tappable.
  eliminated,
}

class GameChoiceButton extends StatelessWidget {
  const GameChoiceButton({
    super.key,
    required this.label,
    this.status = ChoiceStatus.idle,
    this.onPressed,
  });

  final String label;
  final ChoiceStatus status;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (
      Color background,
      Color foreground,
      Color border,
      IconData? icon,
    ) = switch (status) {
      ChoiceStatus.idle => (
        Colors.transparent,
        scheme.onSurface,
        scheme.outline,
        null,
      ),
      ChoiceStatus.correct => (
        AppColors.correct,
        Colors.white,
        AppColors.correct,
        Icons.check_rounded,
      ),
      ChoiceStatus.wrong => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        scheme.error,
        Icons.close_rounded,
      ),
      ChoiceStatus.muted => (
        Colors.transparent,
        scheme.onSurface.withValues(alpha: 0.45),
        scheme.outline.withValues(alpha: 0.4),
        null,
      ),
      ChoiceStatus.eliminated => (
        Colors.transparent,
        scheme.onSurface.withValues(alpha: 0.35),
        scheme.outline.withValues(alpha: 0.25),
        Icons.block,
      ),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      selected: status != ChoiceStatus.idle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 1.5, color: border),
        ),
        child: FilledButton(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(
              Size(double.infinity, 56),
            ),
            // The colour lives on the animated container above; keep the
            // button itself transparent so the transition is visible.
            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            overlayColor: WidgetStatePropertyAll(
              scheme.primary.withValues(alpha: 0.08),
            ),
            foregroundColor: WidgetStatePropertyAll(foreground),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
