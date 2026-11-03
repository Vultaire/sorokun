import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/main.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/hands_free_anzan_setup.dart';
import 'package:soroban_app/screens/hands_free_anzan_session.dart';
import 'package:soroban_app/screens/home_page.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/screens/settings.dart';

Widget _localizedApp(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );

HandsFreeAnzanSetupPage _setupPage({
  required Kyuui kyuui,
  KyuuiDenomination denomination = KyuuiDenomination.zs,
  required ValueChanged<HandsFreeAnzanSetupConfig> onContinue,
}) => HandsFreeAnzanSetupPage(
  kyuui: kyuui,
  denomination: denomination,
  onContinue: onContinue,
);

String _durationText(Duration duration) {
  final seconds = duration.inMilliseconds / Duration.millisecondsPerSecond;
  final formatted = seconds == seconds.roundToDouble()
      ? seconds.toStringAsFixed(0)
      : seconds.toStringAsFixed(1);
  return '$formatted sec';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Combined Subjects menu routes a separate setup handoff', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    SharedPreferences.setMockInitialValues({});
    HandsFreeAnzanSetupConfig? handedOffConfig;
    final router = GoRouter(
      initialLocation: '/paper-menu',
      routes: [
        GoRoute(path: '/paper-menu', builder: (_, _) => const PaperMenuPage()),
        GoRoute(
          path: '/hands-free-anzan-setup',
          builder: (context, state) {
            final request = state.extra as HandsFreeAnzanSetupRequest;
            return HandsFreeAnzanSetupPage(
              kyuui: request.kyuui,
              denomination: request.denomination,
              onContinue: (config) {
                handedOffConfig = config;
                context.pop(config);
              },
            );
          },
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
        locale: const Locale('ja'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('練習'), findsOneWidget);
    expect(find.text('検定'), findsOneWidget);
    expect(find.text('ハンズフリー暗算'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hands-free-anzan-menu-entry')));
    await tester.pumpAndSettle();
    expect(find.text('ハンズフリー暗算の設定'), findsOneWidget);
    expect(find.text('10級 · 全珠連'), findsOneWidget);
    expect(find.text('練習'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('hands-free-setup-continue')),
    );
    await tester.tap(find.byKey(const ValueKey('hands-free-setup-continue')));
    await tester.pumpAndSettle();

    expect(handedOffConfig, isNotNull);
    expect(handedOffConfig!.kyuui, Kyuui.zsk10);
    expect(handedOffConfig!.denomination, KyuuiDenomination.zs);
    expect(handedOffConfig!.mode, HandsFreeAnzanMode.mitori);
    expect(handedOffConfig!.selectedSubjects, {HandsFreeAnzanSubject.mitori});
    expect(find.byType(HandsFreeAnzanSessionPage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('hands-free-current-subject')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('hands-free-stop')));
    await tester.pumpAndSettle();
    expect(find.byType(HandsFreeAnzanSessionPage), findsNothing);
    expect(find.text('練習'), findsOneWidget);
    router.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('setup route without its in-memory request redirects safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    SharedPreferences.setMockInitialValues({'welcome_screen_suppressed': true});
    final appController = AppController(preferredLocales: const [Locale('en')]);
    await appController.ready;
    await tester.pumpWidget(AbacusApp(appController: appController));

    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    router.push('/hands-free-anzan-setup');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(HomePage), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('unavailable subjects are omitted and mixed stays constrained', (
    tester,
  ) async {
    HandsFreeAnzanSetupConfig? config;
    await tester.pumpWidget(
      _localizedApp(
        _setupPage(
          kyuui: Kyuui.nsk10,
          denomination: KyuuiDenomination.ns,
          onContinue: (value) => config = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mitorizan'), findsOneWidget);
    expect(find.text('Mental multiplication'), findsNothing);
    expect(find.text('Mental division'), findsNothing);
    await tester.tap(find.text('Mixed'));
    await tester.pumpAndSettle();

    final mitoriChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('hands-free-subject-mitori')),
    );
    expect(mitoriChip.selected, isTrue);
    expect(
      find.byKey(const ValueKey('hands-free-subject-multiplication')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('hands-free-subject-division')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('hands-free-duration-mitori')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('hands-free-setup-continue')),
    );
    await tester.tap(find.byKey(const ValueKey('hands-free-setup-continue')));
    expect(config!.kyuui, Kyuui.nsk10);
    expect(config!.denomination, KyuuiDenomination.ns);
    expect(config!.mode, HandsFreeAnzanMode.mixed);
    expect(config!.selectedSubjects, {HandsFreeAnzanSubject.mitori});
  });

  testWidgets(
    'Mixed selection and duration previews follow selected subjects',
    (tester) async {
      HandsFreeAnzanSetupConfig? config;
      await tester.pumpWidget(
        _localizedApp(
          _setupPage(kyuui: Kyuui.zsk6, onContinue: (value) => config = value),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mixed'));
      await tester.pumpAndSettle();
      for (final subject in HandsFreeAnzanSubject.values) {
        expect(
          tester
              .widget<FilterChip>(
                find.byKey(ValueKey('hands-free-subject-${subject.name}')),
              )
              .selected,
          isTrue,
        );
        expect(
          find.byKey(ValueKey('hands-free-duration-${subject.name}')),
          findsOneWidget,
        );
      }

      await tester.tap(
        find.byKey(const ValueKey('hands-free-subject-multiplication')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('hands-free-duration-multiplication')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('hands-free-duration-mitori')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('hands-free-duration-division')),
        findsOneWidget,
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(HandsFreeAnzanSetupPage)),
      );
      final selectedSubjects = {
        HandsFreeAnzanSubject.mitori,
        HandsFreeAnzanSubject.division,
      };
      final levels = handsFreeAnzanSubjectsFor(Kyuui.zsk6);
      for (final subject in selectedSubjects) {
        final label = switch (subject) {
          HandsFreeAnzanSubject.mitori => l10n.handsFreeAnzanMitori,
          HandsFreeAnzanSubject.multiplication => l10n.multiplicationAnzan,
          HandsFreeAnzanSubject.division => l10n.divisionAnzan,
        };
        expect(
          find.text(
            l10n.handsFreeAnzanDurationPreview(
              label,
              _durationText(
                handsFreeProblemDuration(levels[subject]!, speedPercent: 100),
              ),
            ),
          ),
          findsOneWidget,
        );
      }

      await tester.ensureVisible(
        find.byKey(const ValueKey('hands-free-setup-continue')),
      );
      await tester.tap(find.byKey(const ValueKey('hands-free-setup-continue')));
      expect(config!.mode, HandsFreeAnzanMode.mixed);
      expect(config!.selectedSubjects, selectedSubjects);
    },
  );

  testWidgets('higher speed shortens per-subject preview and passes speed', (
    tester,
  ) async {
    HandsFreeAnzanSetupConfig? config;
    await tester.pumpWidget(
      _localizedApp(
        _setupPage(kyuui: Kyuui.zsk6, onContinue: (value) => config = value),
      ),
    );
    await tester.pumpAndSettle();

    String mitoriPreviewFor(int speed) =>
        AppLocalizations.of(
          tester.element(find.byType(HandsFreeAnzanSetupPage)),
        ).handsFreeAnzanDurationPreview(
          'Mitorizan',
          _durationText(
            handsFreeProblemDuration(
              Kyuui.zsk6.mitoriAnzan!,
              speedPercent: speed.toDouble(),
            ),
          ),
        );

    expect(find.text(mitoriPreviewFor(100)), findsOneWidget);
    final speedSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('hands-free-speed-slider')),
    );
    expect(speedSlider.min, 50);
    expect(speedSlider.max, 200);
    speedSlider.onChanged!(200);
    await tester.pumpAndSettle();
    expect(find.text(mitoriPreviewFor(200)), findsOneWidget);
    expect(
      handsFreeProblemDuration(Kyuui.zsk6.mitoriAnzan!, speedPercent: 200),
      lessThan(
        handsFreeProblemDuration(Kyuui.zsk6.mitoriAnzan!, speedPercent: 100),
      ),
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('hands-free-setup-continue')),
    );
    await tester.tap(find.byKey(const ValueKey('hands-free-setup-continue')));
    expect(config!.speedPercent, 200);
  });

  testWidgets('answer dwell is separately adjustable and included in handoff', (
    tester,
  ) async {
    HandsFreeAnzanSetupConfig? config;
    await tester.pumpWidget(
      _localizedApp(
        _setupPage(kyuui: Kyuui.zsk6, onContinue: (value) => config = value),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Answer stays visible for 5 sec'), findsOneWidget);
    expect(find.text('Problem display time'), findsOneWidget);
    expect(find.text('Answer display dwell'), findsOneWidget);
    final dwellSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('hands-free-answer-dwell-slider')),
    );
    expect(dwellSlider.min, 1);
    expect(dwellSlider.max, 15);
    expect(dwellSlider.divisions, 14);
    dwellSlider.onChanged!(12);
    await tester.pumpAndSettle();
    expect(find.text('Answer stays visible for 12 sec'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('hands-free-setup-continue')),
    );
    await tester.tap(find.byKey(const ValueKey('hands-free-setup-continue')));
    expect(config!.answerDisplayDwell, const Duration(seconds: 12));
    expect(config!.speedPercent, 100);
  });

  testWidgets('setup remains usable in narrow and wide viewports', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        _localizedApp(_setupPage(kyuui: Kyuui.zsk6, onContinue: (_) {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hands-free Anzan setup'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('hands-free-setup-continue')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  test('setup config rejects unavailable subjects and invalid dwell', () {
    expect(
      () => HandsFreeAnzanSetupConfig(
        kyuui: Kyuui.nsk10,
        denomination: KyuuiDenomination.ns,
        mode: HandsFreeAnzanMode.division,
        selectedSubjects: {HandsFreeAnzanSubject.division},
        speedPercent: 100,
        answerDisplayDwell: const Duration(seconds: 5),
      ),
      throwsArgumentError,
    );
    expect(
      () => HandsFreeAnzanSetupConfig(
        kyuui: Kyuui.nsk10,
        denomination: KyuuiDenomination.ns,
        mode: HandsFreeAnzanMode.mitori,
        selectedSubjects: {HandsFreeAnzanSubject.mitori},
        speedPercent: 100,
        answerDisplayDwell: const Duration(milliseconds: 1500),
      ),
      throwsArgumentError,
    );
  });
}
