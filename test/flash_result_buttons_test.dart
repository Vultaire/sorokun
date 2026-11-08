import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/flash_problem.dart';

const _kanaLocale = Locale.fromSubtags(languageCode: 'ja', scriptCode: 'Kana');

Widget _flashResultHost({
  required Size size,
  required bool isSingleProblem,
  required bool isFinalProblem,
}) {
  final answers = List<String>.filled(15, '123');
  final textData = List.generate(15, (_) => TextFieldData());
  final currentIndex = isFinalProblem ? answers.length - 1 : 0;
  textData[currentIndex].formatted = answers[currentIndex];

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
      builder: (context) => FlashProblemData<String>(
        screenSize: size,
        isPortrait: size.height >= size.width,
        currentProblemIndex: currentIndex,
        allAnswers: answers,
        allProblems: List.generate(answers.length, (_) => ['1', '2', '3']),
        textFieldDataList: textData,
        child: FlashResult<String>(
          onNextProblem: () {},
          inputTime: '1.23',
          isSingleProblem: isSingleProblem,
          onRepeatProblem: () {},
          onNewProblem: () {},
          onShowResults: () {},
        ),
      ),
    ),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _expectLabelFits(
  WidgetTester tester,
  String label, {
  bool oneLine = false,
}) {
  final finder = find.text(label);
  expect(finder, findsOneWidget);
  final text = tester.widget<Text>(finder);
  expect(text.maxLines, 2);
  expect(text.overflow, TextOverflow.ellipsis);

  final painter = TextPainter(
    text: TextSpan(text: text.data, style: text.style),
    textDirection: TextDirection.ltr,
    maxLines: text.maxLines,
    ellipsis: text.overflow == TextOverflow.ellipsis ? '\u2026' : null,
  )..layout(maxWidth: tester.getSize(finder).width);
  expect(
    painter.didExceedMaxLines,
    isFalse,
    reason: '$label must be fully visible in its result button.',
  );
  if (oneLine) {
    expect(
      painter.computeLineMetrics(),
      hasLength(1),
      reason: '$label should fit on one line in its result button.',
    );
  }
  painter.dispose();
}

void main() {
  testWidgets('Kana exam result buttons fit at phone and landscape sizes', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    for (final size in [const Size(390, 844), const Size(844, 390)]) {
      _setViewport(tester, size);
      await tester.pumpWidget(
        _flashResultHost(
          size: size,
          isSingleProblem: false,
          isFinalProblem: false,
        ),
      );
      await tester.pumpAndSettle();

      _expectLabelFits(tester, 'つぎへ', oneLine: true);
      final previousCopyPainter = TextPainter(
        text: TextSpan(
          text: 'つぎのもんだい',
          style: tester.widget<Text>(find.text('つぎへ')).style,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(
        previousCopyPainter.width,
        greaterThan(tester.getSize(find.text('つぎへ')).width),
        reason:
            'The longer previous copy does not fit the result button on one '
            'line, so the concise Kana label should be retained.',
      );
      previousCopyPainter.dispose();

      final nextButton = find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.label.contains('つぎへ') &&
            data.hasAction(SemanticsAction.tap);
      });
      expect(
        nextButton,
        findsOneWidget,
        reason:
            'The next-problem action must expose a tap action in semantics.',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
    semantics.dispose();
  });

  testWidgets('Kana final and free-practice result labels stay readable', (
    tester,
  ) async {
    const size = Size(390, 844);
    _setViewport(tester, size);

    await tester.pumpWidget(
      _flashResultHost(
        size: size,
        isSingleProblem: false,
        isFinalProblem: true,
      ),
    );
    await tester.pumpAndSettle();
    _expectLabelFits(tester, 'こたえあわせ');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _flashResultHost(
        size: size,
        isSingleProblem: true,
        isFinalProblem: false,
      ),
    );
    await tester.pumpAndSettle();
    _expectLabelFits(tester, 'もういっかい');
    _expectLabelFits(tester, 'つぎへ', oneLine: true);
    expect(tester.takeException(), isNull);
  });
}
