import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/l10n/l10n.dart';
import 'package:trivia/models/answered_question.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_outcome.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/ui/widgets/result_share_card.dart';

RoundOutcome _outcome() => RoundOutcome(
  request: const QuizRequest.daily(),
  score: 9,
  answers: [
    AnsweredQuestion(
      trivia: Trivia(
        question: 'Which planet is closest to the sun?',
        answer: 'Mercury',
        choices: const ['Mercury', 'Venus'],
        category: 'science-technology',
      ),
      presentedChoices: const ['Mercury', 'Venus'],
      selectedChoice: 'Mercury',
    ),
  ],
);

Future<void> _pumpCard(WidgetTester tester, {required GlobalKey key}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: key,
            child: ResultShareCard(outcome: _outcome(), streak: 3),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the score, stars and streak', (tester) async {
    final size = tester.view.physicalSize;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(() => tester.view.physicalSize = size);

    await _pumpCard(tester, key: GlobalKey());

    expect(find.text('TriviaHQ'), findsOneWidget);
    expect(find.text('Daily challenge'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('3 day streak'), findsOneWidget);
  });

  // Image encoding only completes on the real event loop, so the capture runs
  // inside `runAsync` rather than in the fake async test zone (where it would
  // never resolve).
  testWidgets('can be captured as a PNG', (tester) async {
    final key = GlobalKey();
    await _pumpCard(tester, key: key);

    await tester.runAsync(() async {
      final bytes = await captureShareCard(key, pixelRatio: 1);

      // The first four bytes of any PNG file.
      expect(bytes.take(4).toList(), [0x89, 0x50, 0x4E, 0x47]);
      expect(bytes.lengthInBytes, greaterThan(1000));
    });
  });

  test('captureShareCard throws when the card is not laid out', () async {
    await expectLater(captureShareCard(GlobalKey()), throwsStateError);
  });
}
