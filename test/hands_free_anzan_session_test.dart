import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/hands_free_anzan_session.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/hands_free_anzan_session.dart';

HandsFreeAnzanSetupConfig _config({
  Kyuui kyuui = Kyuui.zsk10,
  HandsFreeAnzanMode mode = HandsFreeAnzanMode.mitori,
  Set<HandsFreeAnzanSubject>? subjects,
  Duration dwell = const Duration(seconds: 1),
}) => HandsFreeAnzanSetupConfig(
  kyuui: kyuui,
  denomination: KyuuiDenomination.zs,
  mode: mode,
  selectedSubjects: subjects ?? const {HandsFreeAnzanSubject.mitori},
  speedPercent: 100,
  answerDisplayDwell: dwell,
);

Widget _localizedApp(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hands-free Anzan problem queue', () {
    test(
      'mixed cycles are balanced and each subject uses its selected level',
      () {
        final config = _config(
          kyuui: Kyuui.zsk6,
          mode: HandsFreeAnzanMode.mixed,
          subjects: Set.of(HandsFreeAnzanSubject.values),
        );
        final queue = HandsFreeAnzanProblemQueue(config, random: Random(12));

        final firstCycle = List.generate(3, (_) => queue.next());
        expect(
          firstCycle.map((problem) => problem.subject).toSet(),
          config.selectedSubjects,
        );
        for (final problem in firstCycle) {
          expect(problem.level, config.selectedLevels[problem.subject]);
          expect(problem.formattedAnswer, isNotEmpty);
          expect(
            problem.solveDuration(config.speedPercent),
            handsFreeProblemDuration(
              config.selectedLevels[problem.subject]!,
              speedPercent: config.speedPercent.toDouble(),
            ),
          );
        }
        expect(firstCycle.first.subject, isNot(firstCycle.last.subject));
        expect(
          firstCycle
              .singleWhere(
                (problem) => problem.subject == HandsFreeAnzanSubject.mitori,
              )
              .formattedProblem,
          isA<List<String>>(),
        );
        for (final subject in [
          HandsFreeAnzanSubject.multiplication,
          HandsFreeAnzanSubject.division,
        ]) {
          expect(
            firstCycle
                .singleWhere((problem) => problem.subject == subject)
                .formattedProblem,
            isA<String>(),
          );
        }

        final secondCycle = List.generate(3, (_) => queue.next());
        expect(
          secondCycle.map((problem) => problem.subject).toSet(),
          config.selectedSubjects,
        );
        expect(secondCycle.first.subject, isNot(firstCycle.last.subject));
      },
    );

    test('single subject refills its generated set for endless practice', () {
      final queue = HandsFreeAnzanProblemQueue(_config(), random: Random(4));

      final problems = List.generate(12, (_) => queue.next());

      expect(
        problems.every(
          (problem) => problem.subject == HandsFreeAnzanSubject.mitori,
        ),
        isTrue,
      );
      expect(
        problems.every((problem) => problem.formattedAnswer.isNotEmpty),
        isTrue,
      );
    });
  });

  group('hands-free Anzan session', () {
    testWidgets(
      'solve transitions to answer reveal and starts independent dwell',
      (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            HandsFreeAnzanSessionPage(
              config: _config(dwell: const Duration(seconds: 2)),
              durationForLevel: (_, _) => const Duration(milliseconds: 100),
              random: Random(1),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('hands-free-try-again')),
          findsNothing,
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsOneWidget,
        );
        expect(find.textContaining('Questions completed: 1'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('hands-free-attempt-time')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('hands-free-next-countdown')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('hands-free-try-again')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('hands-free-next-problem')),
          findsOneWidget,
        );

        // The two-second answer dwell begins after, rather than inside, the
        // 100ms solve interval.
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('revealed session labels are localized in Japanese', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedApp(
          HandsFreeAnzanSessionPage(
            config: _config(),
            durationForLevel: (_, _) => const Duration(milliseconds: 20),
            random: Random(5),
          ),
          locale: const Locale('ja'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));

      final answer = tester.widget<Text>(
        find.byKey(const ValueKey('hands-free-revealed-answer')),
      );
      expect(answer.data, startsWith('答え：'));
      expect(find.textContaining('練習した問題数：1'), findsOneWidget);
      expect(find.textContaining('この問題の時間：'), findsOneWidget);
      expect(find.textContaining('秒後に次の問題'), findsOneWidget);
    });

    testWidgets(
      'retry repeats the same problem and counts each reveal; next advances',
      (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            HandsFreeAnzanSessionPage(
              config: _config(dwell: const Duration(seconds: 1)),
              durationForLevel: (_, _) => const Duration(milliseconds: 100),
              random: Random(2),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final firstAnswer = tester.widget<Text>(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
        );
        expect(firstAnswer.data, startsWith('Answer: '));
        expect(find.textContaining('Questions completed: 1'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('hands-free-try-again')));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsNothing,
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.textContaining('Questions completed: 2'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('hands-free-next-problem')));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsNothing,
        );
        expect(find.textContaining('Questions completed: 2'), findsNothing);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.textContaining('Questions completed: 3'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'manual retry cancels old dwell timer, failure is stoppable, and disposal cancels timers',
      (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            HandsFreeAnzanSessionPage(
              config: _config(dwell: const Duration(seconds: 1)),
              durationForLevel: (_, _) => const Duration(milliseconds: 100),
              random: Random(3),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byKey(const ValueKey('hands-free-try-again')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 800));
        expect(
          find.byKey(const ValueKey('hands-free-revealed-answer')),
          findsOneWidget,
        );
        expect(find.textContaining('Questions completed: 2'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          _localizedApp(
            HandsFreeAnzanSessionPage(
              config: _config(),
              durationForLevel: (_, _) => throw StateError('bad timer'),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.textContaining('A problem could not be generated'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('hands-free-error-stop')),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Stop returns to Combined Subjects menu', (tester) async {
      final config = _config();
      final router = GoRouter(
        initialLocation: '/paper-menu',
        routes: [
          GoRoute(
            path: '/paper-menu',
            builder: (_, _) => const Scaffold(body: Text('Combined Subjects')),
          ),
          GoRoute(
            path: '/hands-free-anzan-session',
            builder: (_, state) => HandsFreeAnzanSessionPage(
              config: state.extra as HandsFreeAnzanSetupConfig,
              durationForLevel: (_, _) => const Duration(seconds: 30),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      router.push('/hands-free-anzan-session', extra: config);
      await tester.pumpAndSettle();
      expect(find.byType(HandsFreeAnzanSessionPage), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('hands-free-stop')));
      await tester.pumpAndSettle();
      expect(find.text('Combined Subjects'), findsOneWidget);
      expect(find.byType(HandsFreeAnzanSessionPage), findsNothing);
      expect(tester.takeException(), isNull);

      router.dispose();
    });
  });
}
