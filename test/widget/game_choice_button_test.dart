import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/ui/widgets/game_choice_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required String label,
    ChoiceStatus status = ChoiceStatus.idle,
    VoidCallback? onPressed,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameChoiceButton(
            label: label,
            status: status,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the label and reports taps', (tester) async {
    var taps = 0;
    await pumpButton(tester, label: 'Mercury', onPressed: () => taps++);

    expect(find.text('Mercury'), findsOneWidget);
    await tester.tap(find.text('Mercury'));
    expect(taps, 1);
  });

  testWidgets('is not tappable once the answer is locked in', (tester) async {
    await pumpButton(tester, label: 'Mercury');

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('marks the correct answer with a check', (tester) async {
    await pumpButton(
      tester,
      label: 'Mercury',
      status: ChoiceStatus.correct,
      onPressed: () {},
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('marks a wrong pick with a cross', (tester) async {
    await pumpButton(
      tester,
      label: 'Venus',
      status: ChoiceStatus.wrong,
      onPressed: () {},
    );
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('stays neutral while unanswered', (tester) async {
    await pumpButton(tester, label: 'Venus', onPressed: () {});

    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
