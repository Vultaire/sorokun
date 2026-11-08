import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/holistic_hands_free_practice_setup.dart';
import 'package:soroban_app/screens/holistic_hands_free_practice_session.dart';
import 'package:soroban_app/screens/home_page.dart';
import 'package:stroke_text/stroke_text.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );

void _setMockPreferences(Map<String, Object> values) {
  SharedPreferences.setMockInitialValues(values);
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
}

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

  setUp(() => _setMockPreferences({}));

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
    expect(find.text('Practice'), findsOneWidget);
    expect(
      tester.widgetList<StrokeText>(find.byType(StrokeText)).map((e) => e.text),
      contains('Hands-free'),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Practice'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hands-free Practice setup'), findsOneWidget);
    expect(find.text('Practice'), findsNothing);
    expect(tester.takeException(), isNull);
    router.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Japanese home hands-free labels use short katakana forms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      _localizedApp(const HomePage(), locale: const Locale('ja')),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('練習'), findsOneWidget);
    final homeTitles = tester.widgetList<StrokeText>(find.byType(StrokeText));
    expect(homeTitles.map((title) => title.text), contains('ﾊﾝｽﾞ\nﾌﾘｰ'));
    final handsFreeTitle = homeTitles.firstWhere(
      (title) => title.text == 'ﾊﾝｽﾞ\nﾌﾘｰ',
    );
    expect(handsFreeTitle.textStyle?.fontSize, 42);
    expect(handsFreeTitle.strokeWidth, 7);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Kana home titles use compact type to keep labels legible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _localizedApp(
        const HomePage(),
        locale: const Locale.fromSubtags(
          languageCode: 'ja',
          scriptCode: 'Kana',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final kanaTitles = tester
        .widgetList<StrokeText>(find.byType(StrokeText))
        .toList();
    expect(kanaTitles.map((title) => title.text), contains('そうごう\nれんしゅう'));
    expect(kanaTitles.map((title) => title.text), contains('フラッシュ\nあんざん'));
    expect(
      kanaTitles.every((title) => title.textStyle?.fontSize == 24),
      isTrue,
    );
    expect(kanaTitles.every((title) => title.strokeWidth == 4), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Japanese setup uses the concise activity labels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      _localizedApp(
        const HolisticHandsFreePracticeSetupPage(),
        locale: const Locale('ja'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ハンズフリー練習設定'), findsOneWidget);
    expect(find.text('種目の選び方'), findsOneWidget);
    expect(find.text('ランダム'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.textContaining('プレイリスト'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
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

      expect(
        tester
            .widget<DropdownButtonFormField<Denomination>>(
              find.byKey(const ValueKey('holistic-organization-0')),
            )
            .initialValue,
        Denomination.zenshuren,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<Kyuui>>(
              find.byKey(const ValueKey('holistic-grade-0')),
            )
            .initialValue,
        Kyuui.zsk10,
      );

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

  testWidgets('activity changes adopt saved practice and exam levels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    _setMockPreferences({
      'paper_kyuui': Kyuui.nsk6.index,
      'paper_kyuuiDenomination': KyuuiDenomination.ns.index,
      'flash_kyuui': Kyuui.kkk7.index,
      'flash_kyuuiDenomination': KyuuiDenomination.kkFlash.index,
    });
    await tester.pumpWidget(
      _localizedApp(const HolisticHandsFreePracticeSetupPage()),
    );
    await tester.pumpAndSettle();

    await _selectDropdown(
      tester,
      key: 'holistic-activity-0',
      label: 'Mental division',
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Denomination>>(
            find.byKey(const ValueKey('holistic-organization-0')),
          )
          .initialValue,
      Denomination.nisshou,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Kyuui>>(
            find.byKey(const ValueKey('holistic-grade-0')),
          )
          .initialValue,
      Kyuui.nsk6,
    );

    await _selectDropdown(
      tester,
      key: 'holistic-activity-0',
      label: 'Flash Anzan',
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Denomination>>(
            find.byKey(const ValueKey('holistic-organization-0')),
          )
          .initialValue,
      Denomination.kyoukai,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Kyuui>>(
            find.byKey(const ValueKey('holistic-grade-0')),
          )
          .initialValue,
      Kyuui.kkk7,
    );
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('first hands-free item uses saved Soroban Practice level', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    _setMockPreferences({
      'paper_kyuui': Kyuui.nsk6.index,
      'paper_kyuuiDenomination': KyuuiDenomination.ns.index,
    });
    await tester.pumpWidget(
      _localizedApp(const HolisticHandsFreePracticeSetupPage()),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<Denomination>>(
            find.byKey(const ValueKey('holistic-organization-0')),
          )
          .initialValue,
      Denomination.nisshou,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Kyuui>>(
            find.byKey(const ValueKey('holistic-grade-0')),
          )
          .initialValue,
      Kyuui.nsk6,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'playlist entries resolve independently, preserve duplicates, and start the typed session',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      final router = GoRouter(
        initialLocation: '/holistic-hands-free-setup',
        routes: [
          GoRoute(
            path: '/holistic-hands-free-setup',
            builder: (_, _) => const HolisticHandsFreePracticeSetupPage(),
          ),
          GoRoute(
            path: '/holistic-hands-free-session',
            builder: (_, state) {
              return HolisticHandsFreePracticeSessionPage(
                config: state.extra as HolisticHandsFreePracticeConfig,
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
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(HolisticHandsFreePracticeSessionPage), findsOneWidget);
      final config = tester
          .widget<HolisticHandsFreePracticeSessionPage>(
            find.byType(HolisticHandsFreePracticeSessionPage),
          )
          .config;
      expect(config.speedPercent, 200);
      expect(
        config.selectionOrder,
        HolisticHandsFreeSelectionOrder.randomSelection,
      );
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

      await tester.tap(find.byKey(const ValueKey('holistic-session-stop')));
      await tester.pumpAndSettle();
      expect(find.text('Hands-free Practice setup'), findsOneWidget);
      expect(
        tester
            .widget<Slider>(find.byKey(const ValueKey('holistic-speed-slider')))
            .value,
        200,
      );
      router.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets(
    'selection mode and accessible playlist reordering reach the session config',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      final semantics = tester.ensureSemantics();
      final router = GoRouter(
        initialLocation: '/holistic-hands-free-setup',
        routes: [
          GoRoute(
            path: '/holistic-hands-free-setup',
            builder: (_, _) => const HolisticHandsFreePracticeSetupPage(),
          ),
          GoRoute(
            path: '/holistic-hands-free-session',
            builder: (_, state) => HolisticHandsFreePracticeSessionPage(
              config: state.extra as HolisticHandsFreePracticeConfig,
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
      await tester.pumpAndSettle();

      final orderField = find.byKey(const ValueKey('holistic-selection-order'));
      expect(
        tester
            .widget<DropdownButtonFormField<HolisticHandsFreeSelectionOrder>>(
              orderField,
            )
            .initialValue,
        HolisticHandsFreeSelectionOrder.randomSelection,
      );
      expect(find.text('Activity selection'), findsOneWidget);
      expect(find.textContaining('with replacement'), findsNothing);
      expect(find.text('1.'), findsOneWidget);

      final addItem = find.byKey(const ValueKey('holistic-add-item'));
      await tester.ensureVisible(addItem);
      await tester.tap(addItem);
      await tester.pumpAndSettle();
      await _selectDropdown(
        tester,
        key: 'holistic-activity-1',
        label: 'Mental division',
      );

      // The first row cannot move up; the second row's move-up action is both
      // exposed to semantics and performs the same reorder as a pointer tap.
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('holistic-move-up-0')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('holistic-move-down-1')),
            )
            .onPressed,
        isNull,
      );
      final firstMoveUpButton = find.byKey(
        const ValueKey('holistic-move-up-0'),
      );
      await tester.ensureVisible(firstMoveUpButton);
      await tester.pumpAndSettle();
      final disabledMoveUp = find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.tooltip == 'Move activity 1 up' &&
            data.flagsCollection.isEnabled == Tristate.isFalse &&
            !data.hasAction(SemanticsAction.tap);
      });
      expect(disabledMoveUp, findsOneWidget);
      final moveUpButton = find.byKey(const ValueKey('holistic-move-up-1'));
      await tester.ensureVisible(moveUpButton);
      await tester.pumpAndSettle();
      final moveUp = find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.tooltip == 'Move activity 2 up' &&
            data.flagsCollection.isEnabled == Tristate.isTrue &&
            data.hasAction(SemanticsAction.tap);
      });
      expect(moveUp, findsOneWidget);
      tester.semantics.performAction(moveUp, SemanticsAction.tap);
      await tester.pumpAndSettle();

      final moveDown = find.byKey(const ValueKey('holistic-move-down-0'));
      expect(
        tester.widget<IconButton>(moveDown).tooltip,
        'Move activity 1 down',
      );

      await tester.ensureVisible(orderField);
      await tester.tap(orderField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('List order').last);
      await tester.pumpAndSettle();

      final continueButton = find.byKey(
        const ValueKey('holistic-setup-continue'),
      );
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final config = tester
          .widget<HolisticHandsFreePracticeSessionPage>(
            find.byType(HolisticHandsFreePracticeSessionPage),
          )
          .config;
      expect(
        config.selectionOrder,
        HolisticHandsFreeSelectionOrder.playlistOrder,
      );
      expect(config.playlist.map((entry) => entry.activity), [
        HolisticPracticeActivity.divisionAnzan,
        HolisticPracticeActivity.mitoriAnzan,
      ]);
      expect(config.playlist[0].kyuui, Kyuui.zsk6);
      expect(config.playlist[1].kyuui, Kyuui.zsk10);
      expect(tester.takeException(), isNull);

      semantics.dispose();
      router.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets('setup restores the playlist and all practice settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      _localizedApp(const HolisticHandsFreePracticeSetupPage()),
    );
    await tester.pumpAndSettle();

    Future<void> addItem() async {
      final button = find.byKey(const ValueKey('holistic-add-item'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    Future<void> moveItemUp(int index) async {
      final button = find.byKey(ValueKey('holistic-move-up-$index'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await _selectDropdown(tester, key: 'holistic-grade-0', label: '3 kyu');
    await addItem();
    await addItem();
    await _selectDropdown(
      tester,
      key: 'holistic-activity-2',
      label: 'Mental division',
    );
    await addItem();
    await _selectDropdown(
      tester,
      key: 'holistic-activity-3',
      label: 'Flash Anzan',
    );
    await _selectDropdown(
      tester,
      key: 'holistic-organization-3',
      label: 'Japan Flash Anzan Association',
    );
    await _selectDropdown(tester, key: 'holistic-grade-3', label: '7 kyu');
    await moveItemUp(3);
    await moveItemUp(2);

    final order = find.byKey(const ValueKey('holistic-selection-order'));
    await tester.ensureVisible(order);
    await tester.tap(order);
    await tester.pumpAndSettle();
    await tester.tap(find.text('List order').last);
    await tester.pumpAndSettle();

    for (final (key, value) in [
      ('holistic-speed-slider', 175.0),
      ('holistic-thinking-delay-slider', 8.0),
      ('holistic-answer-dwell-slider', 12.0),
    ]) {
      final slider = find.byKey(ValueKey(key));
      await tester.ensureVisible(slider);
      tester.widget<Slider>(slider).onChanged!(value);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _localizedApp(const HolisticHandsFreePracticeSetupPage()),
    );
    await tester.pumpAndSettle();

    final activities = [
      for (var index = 0; index < 4; index++)
        tester
            .widget<DropdownButtonFormField<HolisticPracticeActivity>>(
              find.byKey(ValueKey('holistic-activity-$index')),
            )
            .initialValue,
    ];
    expect(activities, [
      HolisticPracticeActivity.mitoriAnzan,
      HolisticPracticeActivity.flashAnzan,
      HolisticPracticeActivity.mitoriAnzan,
      HolisticPracticeActivity.divisionAnzan,
    ]);
    expect(
      tester
          .widget<DropdownButtonFormField<Denomination>>(
            find.byKey(const ValueKey('holistic-organization-1')),
          )
          .initialValue,
      Denomination.kyoukai,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<Kyuui>>(
            find.byKey(const ValueKey('holistic-grade-1')),
          )
          .initialValue,
      Kyuui.kkk7,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<HolisticHandsFreeSelectionOrder>>(
            find.byKey(const ValueKey('holistic-selection-order')),
          )
          .initialValue,
      HolisticHandsFreeSelectionOrder.playlistOrder,
    );
    expect(
      tester
          .widget<Slider>(find.byKey(const ValueKey('holistic-speed-slider')))
          .value,
      175,
    );
    expect(
      tester
          .widget<Slider>(
            find.byKey(const ValueKey('holistic-thinking-delay-slider')),
          )
          .value,
      8,
    );
    expect(
      tester
          .widget<Slider>(
            find.byKey(const ValueKey('holistic-answer-dwell-slider')),
          )
          .value,
      12,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('wide activity rows keep fields and controls on one line', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      _localizedApp(const HolisticHandsFreePracticeSetupPage()),
    );
    await tester.pumpAndSettle();

    final rowNumber = find.byKey(const ValueKey('holistic-playlist-item-0'));
    final rowCenterY = tester.getCenter(rowNumber).dy;
    for (final key in [
      'holistic-activity-0',
      'holistic-organization-0',
      'holistic-grade-0',
      'holistic-move-up-0',
      'holistic-move-down-0',
      'holistic-remove-item-0',
    ]) {
      expect(
        (tester.getCenter(find.byKey(ValueKey(key))).dy - rowCenterY).abs(),
        lessThan(12),
        reason: '$key should align with the activity number on wide screens',
      );
    }
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'setup sliders expose names and human-readable current semantic values',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _localizedApp(const HolisticHandsFreePracticeSetupPage()),
      );
      await tester.pumpAndSettle();

      Future<void> expectSliderSemantics(
        String key,
        String label,
        String value,
        String increasedValue,
        String decreasedValue,
      ) async {
        final slider = find.byKey(ValueKey(key));
        await tester.ensureVisible(slider);
        await tester.pumpAndSettle();
        expect(tester.widget<Slider>(slider).label, value);
        expect(
          find.semantics.byPredicate((node) {
            final data = node.getSemanticsData();
            return node.label == label &&
                node.value == value &&
                node.increasedValue == increasedValue &&
                node.decreasedValue == decreasedValue &&
                data.flagsCollection.isEnabled != Tristate.none &&
                data.flagsCollection.isEnabled == Tristate.isTrue &&
                data.flagsCollection.isSlider &&
                data.hasAction(SemanticsAction.focus) &&
                data.hasAction(SemanticsAction.increase) &&
                data.hasAction(SemanticsAction.decrease);
          }),
          findsOneWidget,
        );
      }

      await expectSliderSemantics(
        'holistic-speed-slider',
        'Problem display speed',
        'Speed: 100%',
        'Speed: 105%',
        'Speed: 95%',
      );
      await expectSliderSemantics(
        'holistic-thinking-delay-slider',
        'Flash Anzan thinking delay',
        '5 sec',
        '6 sec',
        '4 sec',
      );
      await expectSliderSemantics(
        'holistic-answer-dwell-slider',
        'Answer display time',
        '5 sec',
        '6 sec',
        '4 sec',
      );

      final speedSlider = find.byKey(const ValueKey('holistic-speed-slider'));
      await tester.ensureVisible(speedSlider);
      await tester.pumpAndSettle();
      final speedSemantics = find.semantics.byPredicate(
        (node) =>
            node.label == 'Problem display speed' &&
            node.getSemanticsData().flagsCollection.isSlider,
      );
      tester.semantics.performAction(speedSemantics, SemanticsAction.focus);
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(speedSlider).focusNode!.hasFocus, isTrue);
      tester.semantics.performAction(speedSemantics, SemanticsAction.increase);
      await tester.pumpAndSettle();
      await expectSliderSemantics(
        'holistic-speed-slider',
        'Problem display speed',
        'Speed: 105%',
        'Speed: 110%',
        'Speed: 100%',
      );

      tester
          .widget<Slider>(find.byKey(const ValueKey('holistic-speed-slider')))
          .onChanged!(175);
      tester
          .widget<Slider>(
            find.byKey(const ValueKey('holistic-thinking-delay-slider')),
          )
          .onChanged!(8);
      tester
          .widget<Slider>(
            find.byKey(const ValueKey('holistic-answer-dwell-slider')),
          )
          .onChanged!(12);
      await tester.pumpAndSettle();

      await expectSliderSemantics(
        'holistic-speed-slider',
        'Problem display speed',
        'Speed: 175%',
        'Speed: 180%',
        'Speed: 170%',
      );
      await expectSliderSemantics(
        'holistic-thinking-delay-slider',
        'Flash Anzan thinking delay',
        '8 sec',
        '9 sec',
        '7 sec',
      );
      await expectSliderSemantics(
        'holistic-answer-dwell-slider',
        'Answer display time',
        '12 sec',
        '13 sec',
        '11 sec',
      );

      semantics.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
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
      expect(find.text('Level'), findsOneWidget);
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
    final japaneseTitle = find.text('ハンズフリー練習設定');
    expect(japaneseTitle, findsOneWidget);
    expect(
      tester.renderObject<RenderParagraph>(japaneseTitle).didExceedMaxLines,
      isFalse,
    );
    expect(find.text('種目を追加'), findsOneWidget);
    expect(find.text('級位'), findsOneWidget);
    expect(find.text('フラッシュ暗算の思考時間'), findsOneWidget);
    expect(find.text('種目の選び方'), findsOneWidget);
    expect(find.text('ランダム'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('holistic-move-down-0')),
          )
          .tooltip,
      '種目 1 を下へ移動',
    );
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
