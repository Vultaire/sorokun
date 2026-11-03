import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/flash_problem.dart';

Widget _handsFreeTestApp(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) => FlashProblemData<String>(
        screenSize: const Size(800, 600),
        isPortrait: true,
        currentProblemIndex: 0,
        allAnswers: const ['42'],
        allProblems: const [
          <String>['1'],
        ],
        textFieldDataList: [TextFieldData()],
        child: Scaffold(backgroundColor: Colors.black, body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('hands-free prompt shows the answer prompt and countdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _handsFreeTestApp(
        const FlashHandsFreePrompt(secondsRemaining: 4, totalSeconds: 5),
      ),
    );

    expect(find.text('The answer is…'), findsOneWidget);
    expect(find.text('Answer in 4 seconds'), findsOneWidget);
    expect(find.text('42'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hands-free answer shows session stats and all controls', (
    tester,
  ) async {
    var retries = 0;
    var nextProblems = 0;
    var stops = 0;

    await tester.pumpWidget(
      _handsFreeTestApp(
        FlashHandsFreeResult(
          answer: '42',
          completedQuestions: 3,
          elapsed: const Duration(minutes: 2, seconds: 7),
          secondsRemaining: 5,
          onRepeatProblem: () => retries++,
          onNextProblem: () => nextProblems++,
          onStop: () => stops++,
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('Questions completed: 3'), findsOneWidget);
    expect(find.text('Practice time: 2:07'), findsOneWidget);
    expect(find.text('Next problem in 5 seconds'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Next problem'), findsOneWidget);
    expect(find.text('Stop hands-free'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.tap(find.text('Next problem'));
    await tester.pump();
    await tester.tap(find.text('Stop hands-free'));
    await tester.pump();

    expect(retries, 1);
    expect(nextProblems, 1);
    expect(stops, 1);
  });
}
