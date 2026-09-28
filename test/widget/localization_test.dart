import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/l10n/category_names.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';

void main() {
  Widget localized({String locale = 'en', required Widget child}) =>
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets('switches the semantics label with the locale', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      localized(child: const RatingStars(score: 6, numberOfQuestions: 10)),
    );
    expect(find.bySemanticsLabel('2 out of 3 stars'), findsOneWidget);

    await tester.pumpWidget(
      localized(
        locale: 'es',
        child: const RatingStars(score: 6, numberOfQuestions: 10),
      ),
    );
    expect(find.bySemanticsLabel('2 de 3 estrellas'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('translates category names by slug', (tester) async {
    String label = '';
    await tester.pumpWidget(
      localized(
        locale: 'es',
        child: Builder(
          builder: (context) {
            label = context.l10n.categoryLabel('sports');
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(label, 'Deportes');
  });

  testWidgets('falls back to the slug for an unknown category', (tester) async {
    String label = '';
    await tester.pumpWidget(
      localized(
        child: Builder(
          builder: (context) {
            label = context.l10n.categoryLabel('not-a-category');
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(label, 'not-a-category');
  });
}
