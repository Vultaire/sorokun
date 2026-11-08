import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/paper_results.dart';

const _kanaLocale = Locale.fromSubtags(languageCode: 'ja', scriptCode: 'Kana');

Widget _localizedCountUpCircle(Locale locale) => MaterialApp(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: const Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: CountUpCircle(
          score: (0, 100),
          durationBase: Duration(milliseconds: 10),
          passThreshold: 0.6,
          rangedThreshold: null,
          style: TextStyle(fontSize: 78, fontFamily: 'mPlus'),
          pointsPerProblem: 10,
        ),
      ),
    ),
  ),
);

Widget _localizedReviewButton(Locale locale, {required double width}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: Builder(
              builder: (context) => NavigationButton(
                color: Colors.amber,
                onPressed: () {},
                child: Center(
                  child: iconHelper(
                    context,
                    Icons.error_outline_rounded,
                    AppLocalizations.of(context).reviewMistakesButton,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

Widget _kanaFlashResults() {
  final answers = List<String>.filled(15, '1');
  final textData = List.generate(
    answers.length,
    (_) => TextFieldData()..formatted = '0',
  );

  return MaterialApp(
    locale: _kanaLocale,
    theme: FlexThemeData.light(
      scheme: FlexScheme.shadBlue,
      swapLegacyOnMaterial3: true,
      lightIsWhite: true,
      fontFamily: 'mPlus',
    ),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return ResultsScreen(
          selectedLevel: FlashLevel.zsk20,
          isExam: true,
          examDisplayString: l10n.gradeActivity(
            '20きゅう',
            l10n.flashAnzanSubject,
          ),
          allAnswers: answers,
          allProblems: List.generate(answers.length, (_) => ['1']),
          textFieldDataList: textData,
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('English result score copy reads naturally with a spaced unit', (
    tester,
  ) async {
    await tester.pumpWidget(_localizedCountUpCircle(const Locale('en')));

    expect(find.text('Out of 100 points'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == '0 points',
      ),
      findsNWidgets(2),
    );
    expect(find.text('Failed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Japanese result score keeps its attached points unit', (
    tester,
  ) async {
    await tester.pumpWidget(_localizedCountUpCircle(const Locale('ja')));

    expect(find.text('100点満点'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == '0点',
      ),
      findsNWidgets(2),
    );
    expect(find.text('不合格'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('review action label stays inside its button in both languages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;

    for (final (locale, label) in [
      (const Locale('en'), 'Review mistakes'),
      (const Locale('ja'), '間違えた問題を見る'),
    ]) {
      await tester.pumpWidget(_localizedReviewButton(locale, width: 310));
      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
      final text = tester.widget<Text>(find.text(label));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Kana results return-home action fits and stays accessible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fontLoader = FontLoader('mPlus')
      ..addFont(rootBundle.load('assets/MPLUSRounded1c-Medium.ttf'));
    await fontLoader.load();
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_kanaFlashResults());
    await tester.pump(const Duration(seconds: 3));

    final labelFinder = find.text('ホームにもどる');
    expect(labelFinder, findsOneWidget);
    final text = tester.widget<Text>(labelFinder);
    final labelWidth = tester.getSize(labelFinder).width;
    final conciseLabel = TextPainter(
      text: TextSpan(text: text.data, style: text.style),
      textDirection: TextDirection.ltr,
      maxLines: text.maxLines,
      ellipsis: '\u2026',
    )..layout(maxWidth: labelWidth);
    expect(conciseLabel.didExceedMaxLines, isFalse);
    expect(conciseLabel.computeLineMetrics(), hasLength(1));
    conciseLabel.dispose();

    final previousLabel = TextPainter(
      text: TextSpan(text: 'さいしょのがめんにもどる', style: text.style),
      textDirection: TextDirection.ltr,
    )..layout();
    expect(previousLabel.width, greaterThan(labelWidth));
    previousLabel.dispose();

    final returnHomeButton = find.semantics.byPredicate((node) {
      final data = node.getSemanticsData();
      return data.label.contains('ホームにもどる') &&
          data.hasAction(SemanticsAction.tap);
    });
    expect(returnHomeButton, findsOneWidget);
    expect(tester.takeException(), isNull);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
