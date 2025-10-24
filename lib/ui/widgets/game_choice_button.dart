import 'package:flutter/material.dart';

class GameChoiceButton extends StatelessWidget {
  const GameChoiceButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onPressed,
    required this.outlineColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDefault =
        backgroundColor == theme.colorScheme.onSurface ||
        backgroundColor == Colors.transparent;
    final correctColor = Colors.green;

    // Animated container provides a subtle animation when background color changes
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDefault ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1.5, color: outlineColor),
      ),
      child: FilledButton(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(const Size(double.infinity, 50)),
          // keep button background transparent; we animate the container instead
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),
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
                  ),
                ),
              ),
            ),
            // animated circular indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDefault ? Colors.transparent : backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(width: 1.5, color: outlineColor),
              ),
              child: Center(
                child:
                    isDefault
                        ? const SizedBox.shrink()
                        : (backgroundColor == correctColor
                            ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                            : const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
