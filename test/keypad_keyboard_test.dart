// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/screens/components/keypad.dart';

void main() {
  group('keypad keyboard mapping', () {
    test('maps number-row and numpad digits', () {
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.digit7,
          KeypadType.flash,
        )?.digit,
        '7',
      );
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.numpad3,
          KeypadType.flash,
        )?.digit,
        '3',
      );
    });

    test('maps editing and submit keys', () {
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.backspace,
          KeypadType.flash,
        )?.type,
        KeypadKeyboardCommandType.deleteDigit,
      );
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.delete,
          KeypadType.flash,
        )?.type,
        KeypadKeyboardCommandType.clearAll,
      );
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.numpadEnter,
          KeypadType.flash,
        )?.type,
        KeypadKeyboardCommandType.submit,
      );
    });

    test('maps punctuation and Mitori special key only where supported', () {
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.minus,
          KeypadType.mitori,
        )?.digit,
        '-',
      );
      expect(
        keypadKeyboardCommandFor(LogicalKeyboardKey.minus, KeypadType.divMult),
        isNull,
      );
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.numpadDecimal,
          KeypadType.divMult,
        )?.digit,
        '.',
      );
      expect(
        keypadKeyboardCommandFor(
          LogicalKeyboardKey.keyA,
          KeypadType.mitori,
        )?.digit,
        'a',
      );
      expect(
        keypadKeyboardCommandFor(LogicalKeyboardKey.period, KeypadType.flash),
        isNull,
      );
      expect(
        keypadKeyboardCommandFor(LogicalKeyboardKey.keyA, KeypadType.divMult),
        isNull,
      );
    });
  });

  testWidgets('focused keypad listener dispatches keys without a text field', (
    WidgetTester tester,
  ) async {
    final entered = <String>[];
    var deleted = 0;
    var cleared = 0;
    var submitted = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeypadKeyboardListener(
            keypadType: KeypadType.flash,
            onAppendDigit: entered.add,
            onDeleteDigit: () => deleted++,
            onClearAll: () => cleared++,
            onSubmit: () => submitted++,
            child: const Text('Tap the built-in keypad or type a number'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.numpad8);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(entered, ['8']);
    expect(deleted, 1);
    expect(cleared, 1);
    expect(submitted, 1);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('inactive input and modified browser shortcuts are ignored', (
    WidgetTester tester,
  ) async {
    final entered = <String>[];

    Widget buildListener({required bool enabled}) => MaterialApp(
      home: Scaffold(
        body: KeypadKeyboardListener(
          keypadType: KeypadType.flash,
          enabled: enabled,
          onAppendDigit: entered.add,
          onDeleteDigit: () {},
          onClearAll: () {},
          onSubmit: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.pumpWidget(buildListener(enabled: false));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    expect(entered, isEmpty);

    await tester.pumpWidget(buildListener(enabled: true));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(entered, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    expect(entered, ['4']);
  });
}
