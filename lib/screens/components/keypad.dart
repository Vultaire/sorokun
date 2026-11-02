// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/screens/settings.dart';

import '../../problem_generation/helpers.dart';

class TextFieldData {
  String internalString = '';
  String formatted = '';
  String beforeCaret = '';
  double caretPos = 0.0;
}

class KeypadSounds {
  late final AudioSource keyTap;
  late final AudioSource correct;
  late final AudioSource incorrect;
  late final AudioSource delete;
  late final AudioSource invalid;
  late final AudioSource progress;

  Future<void> init() async {
    try {
      keyTap = await SoLoud.instance.loadAsset('assets/key-tap.wav');
      correct = await SoLoud.instance.loadAsset('assets/correct.wav');
      incorrect = await SoLoud.instance.loadAsset('assets/incorrect.wav');
      delete = await SoLoud.instance.loadAsset('assets/delete.wav');
      invalid = await SoLoud.instance.loadAsset('assets/invalid.wav');
      progress = await SoLoud.instance.loadAsset('assets/progress.wav');
    } catch (e, st) {
      developer.log(
        'Failed to initialize KeypadSounds',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

mixin FlashKeypadMethods<T extends StatefulWidget> on State<T> {
  TextFieldData get textData;
  List<String> get allAnswers;
  int get currentIndex;
  static final _digitsOnlyRegex = RegExp(r'[,.\-]');
  int get maxDigits => 7;
  KeypadSounds get sound;

  void appendDigit(String digit) {
    setState(() {
      if (digit == '-') {
        if (!textData.internalString.startsWith('-')) {
          textData.internalString = '-${textData.internalString}';
          SoLoud.instance.play(sound.keyTap);
        } else {
          textData.internalString = textData.internalString.substring(1);
          SoLoud.instance.play(sound.delete);
        }
      } else if (digit == '.') {
        if (!textData.internalString.contains('.') &&
            textData.internalString.isNotEmpty &&
            textData.internalString != '-') {
          textData.internalString += digit;
          SoLoud.instance.play(sound.keyTap);
        }
      } else if (digit == 'a') {
        if (!textData.internalString.endsWith('a') &&
            textData.internalString.isNotEmpty &&
            textData.internalString != '-') {
          textData.internalString += digit;
          SoLoud.instance.play(sound.keyTap);
        }
      } else if (textData.formatted.replaceAll(_digitsOnlyRegex, '').length <
          maxDigits) {
        textData.internalString += digit;
        SoLoud.instance.play(sound.keyTap);
      } else {
        SoLoud.instance.play(sound.invalid);
      }
      _updateText(textData);
    });
  }

  void _updateText(TextFieldData data) {
    data.formatted = formatWithCommas(data.internalString);
  }

  void deleteDigit() {
    if (textData.internalString.isNotEmpty) {
      setState(() {
        textData.internalString = textData.internalString.substring(
          0,
          textData.internalString.length - 1,
        );
        _updateText(textData);
        SoLoud.instance.play(sound.delete);
      });
    }
  }

  void clearAll() {
    setState(() {
      textData.internalString = '';
      _updateText(textData);
      SoLoud.instance.play(sound.delete);
    });
  }
}

mixin PaperKeypadMethods<T extends StatefulWidget> on State<T> {
  List<TextFieldData> get textFieldDataList;
  int get currentIndex;
  int get maxDigits;
  GlobalKey<ResultPopupState> get resultPopupKey;
  CarouselSliderController get carouselController;
  List<String> get allAnswers;
  bool get isExam;
  VoidCallback get onComplete;
  static final _digitsOnlyRegex = RegExp(r'[,.\-]');
  bool _isSubmitting = false;

  KeypadSounds get sound;

  void appendDigit(String digit) {
    setState(() {
      final data = textFieldDataList[currentIndex];

      if (digit == '-') {
        if (!data.internalString.startsWith('-')) {
          data.internalString = '-${data.internalString}';
          SoLoud.instance.play(sound.keyTap);
        } else {
          data.internalString = data.internalString.substring(1);
          SoLoud.instance.play(sound.delete);
        }
      } else if (digit == '.') {
        if (!data.internalString.contains('.') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
          SoLoud.instance.play(sound.keyTap);
        }
      } else if (digit == 'a') {
        if (!data.internalString.endsWith('a') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
          SoLoud.instance.play(sound.keyTap);
        }
      } else if (data.formatted.replaceAll(_digitsOnlyRegex, '').length <
          maxDigits) {
        data.internalString += digit;
        SoLoud.instance.play(sound.keyTap);
      } else {
        SoLoud.instance.play(sound.invalid);
      }
      _updateText(data);
    });
  }

  void _updateText(TextFieldData data) {
    String result =
        '${data.internalString}b'; // 'b' marks the position of the caret, which must be stored after commas have been applied so we know where to draw the caret.
    bool hasMinusSign = false;
    if (result.startsWith('-')) {
      hasMinusSign = true;
      result = result.substring(1);
    }
    if (result.contains('a')) {
      List<String> parts = result.split('a');
      result = parts.reversed.join('');
    }
    if (hasMinusSign) {
      result = '-$result';
    }
    String formattedWithPlaceholder = formatWithCommas(result);
    int caretIndex = formattedWithPlaceholder.indexOf('b');
    data.formatted = formattedWithPlaceholder.replaceAll('b', '');
    data.beforeCaret = data.formatted.substring(0, caretIndex);
  }

  void deleteDigit() {
    if (textFieldDataList[currentIndex].internalString.isNotEmpty) {
      setState(() {
        final data = textFieldDataList[currentIndex];
        data.internalString = data.internalString.substring(
          0,
          data.internalString.length - 1,
        );
        _updateText(data);
        SoLoud.instance.play(sound.delete);
      });
    }
  }

  void clearAll() {
    setState(() {
      final data = textFieldDataList[currentIndex];
      data.internalString = '';
      _updateText(data);
      SoLoud.instance.play(sound.delete);
    });
  }

  void submit() {
    if (_isSubmitting) return;

    if (textFieldDataList[currentIndex].internalString.isEmpty) {
      SoLoud.instance.play(sound.invalid);
      return;
    }

    _isSubmitting = true;

    final isCorrect = _isAnswerCorrect();

    if (!isExam && !isCorrect) {
      resultPopupKey.currentState?.show(false);
      setState(() {
        final data = textFieldDataList[currentIndex];
        data.internalString = '';
        _updateText(data);
      });
      SoLoud.instance.play(sound.incorrect);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _isSubmitting = false;
      });
      return;
    }

    if (!isExam) {
      resultPopupKey.currentState?.show(true);
      SoLoud.instance.play(sound.correct);
    } else {
      SoLoud.instance.play(sound.progress);
    }

    _moveToNextEmptyQuestion();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _isSubmitting = false;
    });
  }

  bool _isAnswerCorrect() {
    final isCorrect =
        textFieldDataList[currentIndex].formatted == allAnswers[currentIndex];
    return isCorrect;
  }

  void _moveToNextEmptyQuestion() {
    for (var offset = 1; offset <= textFieldDataList.length; offset++) {
      final i = (currentIndex + offset) % textFieldDataList.length;

      if (textFieldDataList[i].internalString.isEmpty) {
        carouselController.animateToPage(
          i,
          curve: Curves.easeInOutCubic,
          duration: Duration(milliseconds: 300),
        );
        return;
      }
    }
    onComplete();
  }
}

class Keypad extends StatelessWidget {
  Keypad({
    super.key,
    required this.onAppendDigit,
    required this.onDeleteDigit,
    required this.onClearAll,
    required this.onSubmit,
    required this.levelType,
  });
  final void Function(String) onAppendDigit;
  final VoidCallback onDeleteDigit;
  final VoidCallback onClearAll;
  final VoidCallback onSubmit;
  final KeypadType levelType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numberRows = InheritedAppController.of(context).numberRows;
    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      // Main keypad
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildKeyRow(context, numberRows[0])),
                const SizedBox(height: 6),
                Expanded(child: _buildKeyRow(context, numberRows[1])),
                const SizedBox(height: 6),
                Expanded(child: _buildKeyRow(context, numberRows[2])),
                const SizedBox(height: 6),
                Expanded(child: _buildBottomRow(context, levelType)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Expanded(
                  child: KeypadButton(
                    color: colorScheme.primaryContainer,
                    margin: EdgeInsets.zero,
                    onTapDown: onDeleteDigit,
                    onLongPress: onClearAll,
                    child: Icon(
                      Icons.backspace_rounded,
                      size: 65,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: KeypadButton(
                    color: colorScheme.primaryContainer,
                    margin: EdgeInsets.zero,
                    onTapDown: onSubmit,
                    child: Icon(
                      Icons.check_rounded,
                      size: 85,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(BuildContext context, List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildKey(context, keys[0])),
        const SizedBox(width: 6),
        Expanded(child: _buildKey(context, keys[1])),
        const SizedBox(width: 6),
        Expanded(child: _buildKey(context, keys[2])),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, KeypadType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case .mitori:
        return Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(child: _buildKey(context, '-')),
            const SizedBox(width: 6),
            Expanded(child: _buildKey(context, '0')),
            const SizedBox(width: 6),
            Expanded(
              child: KeypadButton(
                color: colorScheme.surfaceContainer,
                margin: EdgeInsets.zero,
                onTapDown: () => onAppendDigit('a'),
                child: Transform.rotate(
                  angle: pi,
                  child: Icon(
                    Icons.start,
                    size: 60,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      case .divMult:
        return Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(flex: 2, child: _buildKey(context, '0')),
            const SizedBox(width: 6),
            Expanded(flex: 1, child: _buildKey(context, '.')),
          ],
        );
      case .flash:
        return Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(flex: 1, child: SizedBox.shrink()),
            const SizedBox(width: 6),
            Expanded(flex: 1, child: _buildKey(context, '0')),
            const SizedBox(width: 6),
            Expanded(flex: 1, child: SizedBox.shrink()),
          ],
        );
    }
  }

  Widget _buildKey(BuildContext context, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return KeypadButton(
      color: colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      onTapDown: () => onAppendDigit(value),
      child: Center(
        child: Text(
          value,
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class KeypadButton extends StatefulWidget {
  final VoidCallback onTapDown;
  final VoidCallback? onLongPress;
  final Duration duration;
  final Color color;
  final Widget child;
  final EdgeInsets? margin;
  const KeypadButton({
    super.key,
    required this.onTapDown,
    required this.color,
    required this.child,
    this.onLongPress,
    this.duration = const Duration(milliseconds: 100),
    this.margin,
  });
  @override
  State<KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<KeypadButton> {
  bool _isPressed = false;
  Timer? _longPressTimer;

  void _handleTapDown() {
    setState(() => _isPressed = true);
    widget.onTapDown();
    if (widget.onLongPress != null) {
      _longPressTimer = Timer(const Duration(milliseconds: 500), () {
        widget.onLongPress!();
      });
    }
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _longPressTimer?.cancel();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pressedColor = Color.lerp(widget.color, colorScheme.primary, 0.15)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapUp(),
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.translationValues(0, _isPressed ? 8 : 0.0, 0),
        margin: widget.margin ?? const EdgeInsets.all(0),
        child: AnimatedPhysicalModel(
          duration: widget.duration,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(24),
          color: _isPressed ? pressedColor : widget.color,
          shadowColor: Colors.black,
          elevation: _isPressed ? 2 : 8,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: FittedBox(fit: .scaleDown, child: widget.child),
          ),
        ),
      ),
    );
  }
}

enum KeypadType { divMult, mitori, flash }

enum KeypadKeyboardCommandType { appendDigit, deleteDigit, clearAll, submit }

@immutable
class KeypadKeyboardCommand {
  const KeypadKeyboardCommand.appendDigit(String value)
    : this._(KeypadKeyboardCommandType.appendDigit, value);
  const KeypadKeyboardCommand.deleteDigit()
    : this._(KeypadKeyboardCommandType.deleteDigit);
  const KeypadKeyboardCommand.clearAll()
    : this._(KeypadKeyboardCommandType.clearAll);
  const KeypadKeyboardCommand.submit()
    : this._(KeypadKeyboardCommandType.submit);

  const KeypadKeyboardCommand._(this.type, [this.digit]);

  final KeypadKeyboardCommandType type;
  final String? digit;
}

final _keyboardDigits = <LogicalKeyboardKey, String>{
  LogicalKeyboardKey.digit0: '0',
  LogicalKeyboardKey.digit1: '1',
  LogicalKeyboardKey.digit2: '2',
  LogicalKeyboardKey.digit3: '3',
  LogicalKeyboardKey.digit4: '4',
  LogicalKeyboardKey.digit5: '5',
  LogicalKeyboardKey.digit6: '6',
  LogicalKeyboardKey.digit7: '7',
  LogicalKeyboardKey.digit8: '8',
  LogicalKeyboardKey.digit9: '9',
  LogicalKeyboardKey.numpad0: '0',
  LogicalKeyboardKey.numpad1: '1',
  LogicalKeyboardKey.numpad2: '2',
  LogicalKeyboardKey.numpad3: '3',
  LogicalKeyboardKey.numpad4: '4',
  LogicalKeyboardKey.numpad5: '5',
  LogicalKeyboardKey.numpad6: '6',
  LogicalKeyboardKey.numpad7: '7',
  LogicalKeyboardKey.numpad8: '8',
  LogicalKeyboardKey.numpad9: '9',
};

KeypadKeyboardCommand? keypadKeyboardCommandFor(
  LogicalKeyboardKey key,
  KeypadType keypadType,
) {
  final digit = _keyboardDigits[key];
  if (digit != null) return KeypadKeyboardCommand.appendDigit(digit);

  if (key == LogicalKeyboardKey.backspace) {
    return const KeypadKeyboardCommand.deleteDigit();
  }
  if (key == LogicalKeyboardKey.delete) {
    return const KeypadKeyboardCommand.clearAll();
  }
  if (key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter) {
    return const KeypadKeyboardCommand.submit();
  }
  if (keypadType == KeypadType.mitori &&
      (key == LogicalKeyboardKey.minus ||
          key == LogicalKeyboardKey.numpadSubtract)) {
    return const KeypadKeyboardCommand.appendDigit('-');
  }
  if (keypadType == KeypadType.divMult &&
      (key == LogicalKeyboardKey.period ||
          key == LogicalKeyboardKey.numpadDecimal)) {
    return const KeypadKeyboardCommand.appendDigit('.');
  }
  if (keypadType == KeypadType.mitori && key == LogicalKeyboardKey.keyA) {
    // This is the existing Mitori keypad's auxiliary action; the `a` marker is
    // interpreted by its existing answer formatter.
    return const KeypadKeyboardCommand.appendDigit('a');
  }
  return null;
}

/// Handles physical keyboard input without creating a text-input client.
/// Focus alone does not open the software keyboard on mobile devices.
class KeypadKeyboardListener extends StatelessWidget {
  const KeypadKeyboardListener({
    super.key,
    required this.keypadType,
    required this.onAppendDigit,
    required this.onDeleteDigit,
    required this.onClearAll,
    required this.onSubmit,
    required this.child,
    this.enabled = true,
  });

  final KeypadType keypadType;
  final ValueChanged<String> onAppendDigit;
  final VoidCallback onDeleteDigit;
  final VoidCallback onClearAll;
  final VoidCallback onSubmit;
  final Widget child;
  final bool enabled;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final command = keypadKeyboardCommandFor(event.logicalKey, keypadType);
    if (command == null) return KeyEventResult.ignored;
    if (!enabled) return KeyEventResult.handled;

    switch (command.type) {
      case KeypadKeyboardCommandType.appendDigit:
        onAppendDigit(command.digit!);
      case KeypadKeyboardCommandType.deleteDigit:
        onDeleteDigit();
      case KeypadKeyboardCommandType.clearAll:
        onClearAll();
      case KeypadKeyboardCommandType.submit:
        onSubmit();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(autofocus: true, onKeyEvent: _handleKeyEvent, child: child);
  }
}

class ResultPopup extends StatefulWidget {
  const ResultPopup({super.key});

  @override
  State<ResultPopup> createState() => ResultPopupState();
}

class ResultPopupState extends State<ResultPopup> {
  bool? _isCorrect; // null = hidden
  bool _isRemoving = false;

  void show(bool isCorrect) {
    setState(() {
      _isCorrect = isCorrect;
      _isRemoving = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isRemoving = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCorrect == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_isRemoving),
        tween: Tween(
          begin: _isRemoving ? 1.0 : 0.0,
          end: _isRemoving ? 0.0 : 1.0,
        ),
        duration: Duration(milliseconds: _isRemoving ? 120 : 50),
        onEnd: () {
          if (_isRemoving) {
            setState(() {
              _isCorrect = null;
            });
          }
        },
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Image.asset(
              _isCorrect! ? 'assets/correct.png' : 'assets/incorrect.png',
              width: 300,
              height: 300,
            ),
          );
        },
      ),
    );
  }
}
