import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';
import 'package:trivia/utils/scoring.dart';

import '../helpers.dart';

void main() {
  Future<void> pumpStars(
    WidgetTester tester, {
    required int score,
    required int total,
  }) {
    return tester.pumpWidget(
      localizedApp(RatingStars(score: score, numberOfQuestions: total)),
    );
  }

  testWidgets('always renders exactly maxStars stars', (tester) async {
    await pumpStars(tester, score: 0, total: 10);
    expect(find.byIcon(Icons.star_rate_rounded), findsNWidgets(maxStars));
  });

  testWidgets('highlights every star for a perfect round', (tester) async {
    await pumpStars(tester, score: 10, total: 10);

    final context = tester.element(find.byType(RatingStars));
    final highlight = Theme.of(context).colorScheme.primary;
    final icons =
        tester.widgetList<Icon>(find.byIcon(Icons.star_rate_rounded)).toList();

    expect(icons.every((icon) => icon.color == highlight), isTrue);
  });

  testWidgets('leaves every star unhighlighted for a scoreless round', (
    tester,
  ) async {
    await pumpStars(tester, score: 0, total: 10);

    final context = tester.element(find.byType(RatingStars));
    final scheme = Theme.of(context).colorScheme;
    final icons =
        tester.widgetList<Icon>(find.byIcon(Icons.star_rate_rounded)).toList();

    expect(
      icons.every((icon) => icon.color == scheme.primaryContainer),
      isTrue,
    );
  });

  testWidgets('does not throw for an empty round', (tester) async {
    await pumpStars(tester, score: 0, total: 0);

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.star_rate_rounded), findsNWidgets(maxStars));
  });

  testWidgets('describes the rating for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpStars(tester, score: 6, total: 10);

    expect(find.bySemanticsLabel('2 out of 3 stars'), findsOneWidget);
    handle.dispose();
  });
}
