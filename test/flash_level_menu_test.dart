import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/grade_reference_info_button.dart';
import 'package:soroban_app/screens/flash_level_menu.dart';

double _unwrappedTextWidth(Text text) {
  final painter = TextPainter(
    text: TextSpan(text: text.data, style: text.style),
    textDirection: TextDirection.ltr,
    textAlign: text.textAlign ?? TextAlign.start,
  )..layout();
  return painter.width;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fontLoader = FontLoader('mPlus')
      ..addFont(rootBundle.load('assets/MPLUSRounded1c-Medium.ttf'));
    await fontLoader.load();
  });

  Future<void> pumpKanaExamMenu(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    const kanaLocale = Locale.fromSubtags(
      languageCode: 'ja',
      scriptCode: 'Kana',
    );
    final testTheme = FlexThemeData.light(
      scheme: FlexScheme.shadBlue,
      swapLegacyOnMaterial3: true,
      lightIsWhite: true,
      fontFamily: 'mPlus',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: kanaLocale,
        theme: testTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const FlashLevelMenuPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Kana Flash exam title clears the grade-info action', (
    tester,
  ) async {
    await pumpKanaExamMenu(tester);

    final titleFinder = find.text('フラッシュあんざんもぎテスト');
    expect(titleFinder, findsOneWidget);
    expect(tester.widget<Text>(titleFinder).data, 'フラッシュあんざんもぎテスト');
    final titleFit = find.ancestor(
      of: titleFinder,
      matching: find.byType(FittedBox),
    );
    expect(titleFit, findsOneWidget);
    final infoButtonRect = tester.getRect(
      find.byType(GradeReferenceInfoButton),
    );
    final titleCenterX =
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
    expect(
      tester.getSize(titleFit).width,
      lessThanOrEqualTo(2 * (infoButtonRect.left - titleCenterX)),
      reason: 'The Kana title must not run under the grade-reference button.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kana Flash exam association selector shows its full label', (
    tester,
  ) async {
    await pumpKanaExamMenu(tester);

    final labelFinder = find.text('あんざんきょうかい');
    expect(labelFinder, findsOneWidget);
    final label = tester.widget<Text>(labelFinder);
    final labelWidth = _unwrappedTextWidth(label);
    final segmentTextWidth = tester.getSize(labelFinder).width;
    expect(
      labelWidth,
      lessThanOrEqualTo(segmentTextWidth),
      reason:
          'The association label must fit within its segment without clipping.',
    );
  });

  testWidgets('Kana exam labels remain visible on a narrow phone', (
    tester,
  ) async {
    await pumpKanaExamMenu(tester, size: const Size(320, 568));

    final titleFinder = find.text('フラッシュあんざんもぎテスト');
    expect(titleFinder, findsOneWidget);
    expect(tester.widget<Text>(titleFinder).data, 'フラッシュあんざんもぎテスト');
    final titleFit = find.ancestor(
      of: titleFinder,
      matching: find.byType(FittedBox),
    );
    expect(titleFit, findsOneWidget);
    final infoButtonRect = tester.getRect(
      find.byType(GradeReferenceInfoButton),
    );
    final titleCenterX =
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
    expect(
      tester.getSize(titleFit).width,
      lessThanOrEqualTo(2 * (infoButtonRect.left - titleCenterX)),
      reason: 'The full Kana exam title must fit beside the info button.',
    );

    final label = tester.widget<Text>(find.text('あんざんきょうかい'));
    expect(
      _unwrappedTextWidth(label),
      lessThanOrEqualTo(tester.getSize(find.text('あんざんきょうかい')).width),
      reason: 'The full association label must fit at 320 px.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kana grade labels never wrap in the carousel', (tester) async {
    // displaySmall lines are ~53 px tall; a wrapped label is ~106 px. The
    // carousel FittedBox lays each label out unconstrained on one line and
    // scales it to fit the page, so any taller box means the label wrapped
    // and would be clipped by the carousel viewport.
    for (final size in [const Size(390, 844), const Size(844, 390)]) {
      await pumpKanaExamMenu(tester, size: size);
      for (final label in ['20きゅう', '19きゅう', 'じゅうだん']) {
        for (final element in find.text(label).evaluate()) {
          final finder = find.byElementPredicate((e) => identical(e, element));
          expect(
            tester.getSize(finder).height,
            lessThanOrEqualTo(60.0),
            reason:
                '$label must lay out on a single line at ${size.width}x'
                '${size.height} so the carousel does not clip it.',
          );
          expect(
            find.ancestor(of: finder, matching: find.byType(FittedBox)),
            findsWidgets,
            reason: '$label must be scaled to fit its carousel page.',
          );
        }
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Kana exam setup lays out in compact landscape and wide view', (
    tester,
  ) async {
    for (final size in [
      const Size(844, 390),
      const Size(800, 1280),
      const Size(1440, 900),
    ]) {
      await pumpKanaExamMenu(tester, size: size);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Flash exam menu should lay out at $size without overflow.',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
