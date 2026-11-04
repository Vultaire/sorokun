import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/holistic_hands_free_session.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/holistic_hands_free_practice_session.dart';

HolisticPracticePlaylistEntry _paperEntry() =>
    HolisticPracticePlaylistEntry.paperAnzan(
      activity: HolisticPracticeActivity.mitoriAnzan,
      denomination: Denomination.zenshuren,
      kyuui: Kyuui.zsk10,
    );

HolisticPracticePlaylistEntry _flashEntry() =>
    HolisticPracticePlaylistEntry.flashAnzan(
      denomination: Denomination.zenshuren,
      kyuui: Kyuui.zsk20,
    );

HolisticHandsFreePracticeConfig _config(
  Iterable<HolisticPracticePlaylistEntry> playlist, {
  Duration thinkingDelay = const Duration(seconds: 1),
  Duration answerDisplayDwell = const Duration(seconds: 1),
}) => HolisticHandsFreePracticeConfig(
  playlist: playlist,
  thinkingDelay: thinkingDelay,
  answerDisplayDwell: answerDisplayDwell,
);

typedef _Harness = ({Widget app, GoRouter router});

_Harness _app({
  required HolisticHandsFreePracticeConfig config,
  required HolisticHandsFreeProblemSetGenerator generator,
  required Duration Function(HolisticPracticePlaylistEntry, int) duration,
  Locale locale = const Locale('en'),
}) {
  final router = GoRouter(
    initialLocation: '/setup',
    routes: [
      GoRoute(
        path: '/setup',
        builder: (_, _) => _TestSetupPage(config: config),
      ),
      GoRoute(
        path: '/session',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: HolisticHandsFreePracticeSessionPage(
            config: state.extra as HolisticHandsFreePracticeConfig,
            random: Random(42),
            problemSetGenerator: generator,
            durationForEntry: duration,
          ),
        ),
      ),
    ],
  );
  return (
    app: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    ),
    router: router,
  );
}

Future<void> _startSession(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(harness.app);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('test-start-session')));
  await tester.pump();
}

class _TestSetupPage extends StatelessWidget {
  const _TestSetupPage({required this.config});

  final HolisticHandsFreePracticeConfig config;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Setup remains here'),
          FilledButton(
            key: const ValueKey('test-start-session'),
            onPressed: () => context.push('/session', extra: config),
            child: const Text('Start'),
          ),
        ],
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'paper problem hides answers; retry retains exact item; Next advances',
    (tester) async {
      final config = _config([_paperEntry()]);
      var generatedSets = 0;
      final harness = _app(
        config: config,
        duration: (_, _) => const Duration(seconds: 2),
        generator: (_, _) {
          generatedSets++;
          return [
            const HolisticHandsFreeGeneratedProblem(
              formattedPrompt: ['1', '2'],
              formattedAnswer: 'answer-first',
            ),
            const HolisticHandsFreeGeneratedProblem(
              formattedPrompt: ['3', '4'],
              formattedAnswer: 'answer-second',
            ),
          ];
        },
      );
      await _startSession(tester, harness);

      expect(
        find.byKey(const ValueKey('holistic-session-subject')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('holistic-session-level')),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      expect(find.textContaining('answer-first'), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-session-answer')))
            .data,
        contains('answer-first'),
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('holistic-session-attempt-count')),
            )
            .data,
        'Questions completed: 1',
      );
      expect(find.textContaining('Practice time:'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('holistic-session-try-again')),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      expect(find.text('1'), findsOneWidget);
      expect(generatedSets, 1);

      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-session-answer')))
            .data,
        contains('answer-first'),
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('holistic-session-attempt-count')),
            )
            .data,
        'Questions completed: 2',
      );

      await tester.tap(find.byKey(const ValueKey('holistic-session-next')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      expect(find.text('3'), findsOneWidget);
      expect(generatedSets, 1);

      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-session-answer')))
            .data,
        contains('answer-second'),
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('holistic-session-attempt-count')),
            )
            .data,
        'Questions completed: 3',
      );
      harness.router.dispose();
    },
  );

  testWidgets(
    'Flash stream and thinking delay are separate from answer dwell',
    (tester) async {
      final config = _config(
        [_flashEntry()],
        thinkingDelay: const Duration(milliseconds: 400),
        answerDisplayDwell: const Duration(milliseconds: 600),
      );
      var generatedSets = 0;
      final harness = _app(
        config: config,
        duration: (_, _) => const Duration(milliseconds: 200),
        generator: (_, _) {
          generatedSets++;
          return [
            const HolisticHandsFreeGeneratedProblem(
              formattedPrompt: ['7', '8'],
              flashNumbers: ['7', '8'],
              formattedAnswer: '15',
            ),
          ];
        },
      );
      await _startSession(tester, harness);

      expect(find.text('7'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const ValueKey('holistic-session-thinking-countdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );

      await tester.pump(const Duration(milliseconds: 399));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-session-answer')))
            .data,
        'Answer: 15',
      );

      await tester.pump(const Duration(milliseconds: 599));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('holistic-session-problem-countdown')),
        findsOneWidget,
      );
      expect(generatedSets, 2);
      harness.router.dispose();
    },
  );

  testWidgets(
    'dwell expiry automatically advances and regenerates an exhausted set',
    (tester) async {
      final config = _config([
        _paperEntry(),
      ], answerDisplayDwell: const Duration(milliseconds: 300));
      var generatedSets = 0;
      final harness = _app(
        config: config,
        duration: (_, _) => const Duration(milliseconds: 200),
        generator: (_, _) {
          generatedSets++;
          return [
            HolisticHandsFreeGeneratedProblem(
              formattedPrompt: ['$generatedSets'],
              formattedAnswer: 'answer-$generatedSets',
            ),
          ];
        },
      );
      await _startSession(tester, harness);

      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 299));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.byKey(const ValueKey('holistic-session-answer')),
        findsNothing,
      );
      expect(find.text('2'), findsOneWidget);
      expect(generatedSets, 2);
      harness.router.dispose();
    },
  );

  testWidgets(
    'Stop returns to the pushed setup and generation errors can stop',
    (tester) async {
      final config = _config([_paperEntry()]);
      final harness = _app(
        config: config,
        duration: (_, _) => const Duration(hours: 1),
        generator: (_, _) => throw StateError('synthetic generation error'),
      );
      await _startSession(tester, harness);

      expect(
        find.byKey(const ValueKey('holistic-session-error')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('holistic-session-stop')));
      await tester.pumpAndSettle();
      expect(find.text('Setup remains here'), findsOneWidget);
      expect(tester.takeException(), isNull);
      harness.router.dispose();
    },
  );

  testWidgets('route disposal cancels phase timers and tickers', (
    tester,
  ) async {
    final config = _config([_paperEntry()]);
    var generatedSets = 0;
    final harness = _app(
      config: config,
      duration: (_, _) => const Duration(seconds: 20),
      generator: (_, _) {
        generatedSets++;
        return const [
          HolisticHandsFreeGeneratedProblem(
            formattedPrompt: ['1'],
            formattedAnswer: '2',
          ),
        ];
      },
    );
    await _startSession(tester, harness);
    expect(generatedSets, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 25));
    expect(generatedSets, 1);
    expect(tester.takeException(), isNull);
    harness.router.dispose();
  });

  testWidgets('session fits compact portrait, landscape, and large displays', (
    tester,
  ) async {
    for (final size in [
      const Size(320, 640),
      const Size(640, 320),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final harness = _app(
        config: _config([_paperEntry()]),
        duration: (_, _) => const Duration(hours: 1),
        generator: (_, _) => const [
          HolisticHandsFreeGeneratedProblem(
            formattedPrompt: ['12345678901234567890', '98765432109876543210'],
            formattedAnswer: '12345678901234567890',
          ),
        ],
      );
      await _startSession(tester, harness);
      expect(find.byType(HolisticHandsFreePracticeSessionPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      harness.router.dispose();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Japanese session labels are localized', (tester) async {
    final harness = _app(
      config: _config([_paperEntry()]),
      duration: (_, _) => const Duration(hours: 1),
      generator: (_, _) => const [
        HolisticHandsFreeGeneratedProblem(
          formattedPrompt: ['1', '2'],
          formattedAnswer: '3',
        ),
      ],
      locale: const Locale('ja'),
    );
    await _startSession(tester, harness);

    expect(find.text('みとり暗算'), findsOneWidget);
    expect(find.textContaining('終了まで'), findsOneWidget);
    expect(find.text('ハンズフリーを終了'), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.router.dispose();
  });
}
