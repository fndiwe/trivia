import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trivia/l10n/category_names.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/models/round_outcome.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';

/// Logical size the card is laid out at; [captureShareCard] renders it at a
/// higher pixel ratio for a crisp image.
const Size shareCardSize = Size(360, 560);

/// A shareable image of a finished round.
///
/// It is meant to be rendered inside a [RepaintBoundary] (hidden with an
/// `Opacity` of 0 and an `IgnorePointer`) and captured to a PNG via
/// [captureShareCard].
class ResultShareCard extends StatelessWidget {
  const ResultShareCard({super.key, required this.outcome, this.streak = 0});

  final RoundOutcome outcome;

  /// The player's current day streak, shown as a small brag line.
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stars = starsFor(outcome.score, outcome.total);
    final mode = outcome.request.mode;
    final modeLabel = switch (mode) {
      RoundMode.level => context.l10n.levelLabel(
        outcome.request.level?.id ?? 0,
      ),
      RoundMode.category => context.l10n.categoryLabel(
        outcome.request.category?.categoryId ?? '',
      ),
      RoundMode.daily => context.l10n.modeDaily,
      RoundMode.practice => context.l10n.modePractice,
    };

    return Material(
      color: scheme.primary,
      child: SizedBox(
        width: shareCardSize.width,
        height: shareCardSize.height,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'TriviaHQ',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modeLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${outcome.score}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/${outcome.total}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RatingStars(
                score: outcome.score,
                numberOfQuestions: outcome.total,
                size: 40,
                center: true,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.starsOf(stars),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (streak > 0) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.streakBadge(streak),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                context.l10n.canYouBeatMe,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

/// Captures the widget inside [boundaryKey] as PNG bytes.
///
/// The boundary must be laid out and painted (e.g. hidden with an `Opacity` of
/// 0, not an `Offstage`). Throws a [StateError] when the card is not ready.
Future<Uint8List> captureShareCard(
  GlobalKey boundaryKey, {
  double pixelRatio = 2.5,
}) async {
  final context = boundaryKey.currentContext;
  final boundary = context?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('The share card is not laid out yet.');
  }
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Could not encode the share card.');
  }
  return byteData.buffer.asUint8List();
}
