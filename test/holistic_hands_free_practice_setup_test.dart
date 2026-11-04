import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/holistic_hands_free_practice_setup.dart';
import 'package:soroban_app/screens/home_page.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );

Future<void> _selectDropdown(
  WidgetTester tester, {
  required String key,
  required String label,
}) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home has a distinct hands-free choice and opens its setup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomePage()),
        GoRoute(
          path: '/holistic-hands-free-setup',
          builder: (_, _) => const HolisticHandsFreePracticeSetupPage(),
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
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Choose a subject'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Hands-free Practice'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Hands-free Practice'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hands-free Practice setup'), findsOneWidget);
    expect(find.text('Hands-free Practice'), findsNothing);
    expect(tester.takeException(), isNull);
    router.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'activity and organization changes filter invalid grade options',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        _localizedApp(const HolisticHandsFreePracticeSetupPage()),
      );
      await tester.pumpAndSettle();

      final organization = find.byKey(
        const ValueKey('holistic-organization-0'),
      );
      await tester.tap(organization);
      await tester.pumpAndSettle();
      expect(find.text('Nisshuren'), findsOneWidget);
      expect(find.text('Japan Flash Anzan Association'), findsNothing);
      await tester.tap(find.text('Zenshuren').last);
      await tester.pumpAndSettle();

      await _selectDropdown(
        tester,
        key: 'holistic-activity-0',
        label: 'Flash Anzan',
      );
      await tester.ensureVisible(organization);
      await tester.tap(organization);
      await tester.pumpAndSettle();
      expect(find.text('Japan Flash Anzan Association'), findsOneWidget);
      expect(find.text('Nisshuren'), findsNothing);
      await tester.tap(find.text('Japan Flash Anzan Association'));
      await tester.pumpAndSettle();

      final grade = find.byKey(const ValueKey('holistic-grade-0'));
      await tester.ensureVisible(grade);
      await tester.tap(grade);
      await tester.pumpAndSettle();
      expect(find.text('7 kyu'), findsOneWidget);
      expect(find.text('Nisshuren'), findsNothing);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets(
    'playlist entries resolve independently, preserve duplicates, and hand off typed settings',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      HolisticHandsFreePracticeConfig? handedOffConfig;
      final router = GoRouter(
        initialLocation: '/holistic-hands-free-setup',
        routes: [
          GoRoute(
            path: '/holistic-hands-free-setup',
            builder: (_, _) => const HolisticHandsFreePracticeSetupPage(),
          ),
          GoRoute(
            path: '/holistic-hands-free-handoff',
            builder: (context, state) {
              final config = state.extra as HolisticHandsFreePracticeConfig;
              handedOffConfig = config;
              return HolisticHandsFreeHandoffPage(
                config: config,
                onBack: () => context.pop(),
              );
            },
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
      await tester.pumpAndSettle();

      Future<void> addItem() async {
        final button = find.byKey(const ValueKey('holistic-add-item'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      Future<void> removeItem(int index) async {
        final button = find.byKey(ValueKey('holistic-remove-item-$index'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      // Zenshuren 3-kyu Mitorizan; a second identical row intentionally adds
      // another unit of playlist weight.
      await _selectDropdown(tester, key: 'holistic-grade-0', label: '3 kyu');
      await addItem();

      // Zenshuren 3-kyu division.
      await addItem();
      await _selectDropdown(
        tester,
        key: 'holistic-activity-2',
        label: 'Mental division',
      );

      // Zenshuren 4-kyu multiplication.
      await addItem();
      await _selectDropdown(
        tester,
        key: 'holistic-activity-3',
        label: 'Mental multiplication',
      );
      await _selectDropdown(tester, key: 'holistic-grade-3', label: '4 kyu');

      // Association Flash Anzan at 7-kyu and 6-kyu.
      await addItem();
      await _selectDropdown(
        tester,
        key: 'holistic-activity-4',
        label: 'Flash Anzan',
      );
      await _selectDropdown(
        tester,
        key: 'holistic-organization-4',
        label: 'Japan Flash Anzan Association',
      );
      await _selectDropdown(tester, key: 'holistic-grade-4', label: '7 kyu');
      await addItem();
      await _selectDropdown(tester, key: 'holistic-grade-5', label: '6 kyu');
      await addItem();
      await removeItem(6);
      expect(
        find.byKey(const ValueKey('holistic-playlist-item-6')),
        findsNothing,
      );

      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-duration-0')))
            .data,
        contains('9 sec'),
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-current-speed')))
            .data,
        'Speed: 100%',
      );
      final speed = tester.widget<Slider>(
        find.byKey(const ValueKey('holistic-speed-slider')),
      );
      expect(speed.min, 50);
      expect(speed.max, 200);
      expect(speed.value, 100);
      speed.onChanged!(200);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-current-speed')))
            .data,
        'Speed: 200%',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('holistic-duration-0')))
            .data,
        contains('4.5 sec'),
      );

      final thinkingDelay = tester.widget<Slider>(
        find.byKey(const ValueKey('holistic-thinking-delay-slider')),
      );
      final answerDwell = tester.widget<Slider>(
        find.byKey(const ValueKey('holistic-answer-dwell-slider')),
      );
      expect(thinkingDelay.value, 5);
      expect(answerDwell.value, 5);
      thinkingDelay.onChanged!(8);
      answerDwell.onChanged!(3);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('holistic-thinking-delay-value')),
            )
            .data,
        '8 sec',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('holistic-answer-dwell-value')),
            )
            .data,
        '3 sec',
      );

      final continueButton = find.byKey(
        const ValueKey('holistic-setup-continue'),
      );
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.byType(HolisticHandsFreeHandoffPage), findsOneWidget);
      expect(
        find.textContaining('No practice session has started'),
        findsOneWidget,
      );
      expect(handedOffConfig, isNotNull);
      final config = handedOffConfig!;
      expect(config.speedPercent, 200);
      expect(config.thinkingDelay, const Duration(seconds: 8));
      expect(config.answerDisplayDwell, const Duration(seconds: 3));
      expect(config.playlist, hasLength(6));
      expect(config.playlist.map((entry) => entry.activity), [
        HolisticPracticeActivity.mitoriAnzan,
        HolisticPracticeActivity.mitoriAnzan,
        HolisticPracticeActivity.divisionAnzan,
        HolisticPracticeActivity.multiplicationAnzan,
        HolisticPracticeActivity.flashAnzan,
        HolisticPracticeActivity.flashAnzan,
      ]);
      expect(config.playlist[0].kyuui, Kyuui.zsk3);
      expect(config.playlist[1].kyuui, Kyuui.zsk3);
      expect(config.playlist[2].kyuui, Kyuui.zsk3);
      expect(config.playlist[3].kyuui, Kyuui.zsk4);
      expect(config.playlist[4].denomination, Denomination.kyoukai);
      expect(config.playlist[4].kyuui, KyuuiDenomination.kkFlash.k7);
      expect(config.playlist[5].denomination, Denomination.kyoukai);
      expect(config.playlist[5].kyuui, KyuuiDenomination.kkFlash.k6);
      expect(tester.takeException(), isNull);
      router.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets('setup is localized and fits phone, tablet, and desktop widths', (
    tester,
  ) async {
    for (final size in [
      const Size(320, 640),
      const Size(768, 1024),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        _localizedApp(const HolisticHandsFreePracticeSetupPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hands-free Practice setup'), findsOneWidget);
      expect(find.byKey(const ValueKey('holistic-add-item')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('holistic-setup-continue')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      _localizedApp(
        const HolisticHandsFreePracticeSetupPage(),
        locale: const Locale('ja'),
      ),
    );
    await tester.pumpAndSettle();
    final japaneseTitle = find.text('ハンズフリー総合設定');
    expect(japaneseTitle, findsOneWidget);
    expect(
      tester.renderObject<RenderParagraph>(japaneseTitle).didExceedMaxLines,
      isFalse,
    );
    expect(find.text('プレイリスト項目を追加'), findsOneWidget);
    expect(find.text('フラッシュ暗算の思考時間'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
