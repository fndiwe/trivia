import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/ui/widgets/daily_challenge_card.dart';

import 'package:trivia/l10n/l10n.dart';

import '../helpers.dart';

void main() {
  testWidgets('daily challenge card shows the open state', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      localizedApp(
        DailyChallengeCard(done: false, onPlay: () => tapped = true),
      ),
    );

    expect(find.text('Daily challenge'), findsOneWidget);
    expect(
      find.text('Ten questions, the same for everyone today'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await tester.tap(find.text('Daily challenge'));
    expect(tapped, isTrue);
  });

  testWidgets('daily challenge card shows the done state', (tester) async {
    await tester.pumpWidget(
      localizedApp(DailyChallengeCard(done: true, onPlay: () {})),
    );

    expect(find.text('Done for today - come back tomorrow'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('practice card reports the queue size', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      localizedApp(PracticeCard(count: 4, onPlay: () => tapped = true)),
    );

    expect(find.text('Practise your mistakes'), findsOneWidget);
    expect(find.text('4 questions to work on'), findsOneWidget);

    await tester.tap(find.text('Practise your mistakes'));
    expect(tapped, isTrue);
  });

  testWidgets('streak badge announces the streak to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(localizedApp(const StreakBadge(streak: 5)));

    expect(find.text('5'), findsOneWidget);
    expect(find.bySemanticsLabel('5 day streak'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('streak badge is localized', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: StreakBadge(streak: 5)),
      ),
    );

    expect(find.bySemanticsLabel('5 días seguidos'), findsOneWidget);
  });
}
