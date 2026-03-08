import 'dart:math';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

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
    } catch (e) {
      print('Error initializing SoundController: $e');
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
  CarouselSliderController get carouselController;
  List<String> get allAnswers;
  bool get isExam;
  VoidCallback get onComplete;
  static final _digitsOnlyRegex = RegExp(r'[,.\-]');

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
    if (textFieldDataList[currentIndex].internalString.isEmpty) {
      SoLoud.instance.play(sound.invalid);
      return;
    }

    final isCorrect = _isAnswerCorrect();

    if (!isExam && !isCorrect) {
      showResultPopup(context, false);
      setState(() {
        final data = textFieldDataList[currentIndex];
        data.internalString = '';
        _updateText(data);
      });
      SoLoud.instance.play(sound.incorrect);
      return;
    }

    if (!isExam) {
      showResultPopup(context, true);
      SoLoud.instance.play(sound.correct);
    } else {
      SoLoud.instance.play(sound.progress);
    }

    _moveToNextEmptyQuestion();
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
          curve: Curves.easeOutExpo,
          duration: Duration(milliseconds: 500),
        );
        return;
      }
    }
    onComplete();
  }

  void showResultPopup(BuildContext context, bool isCorrect) {
    late OverlayEntry overlayEntry;
    bool isRemoving = false;

    overlayEntry = OverlayEntry(
      builder: (context) => IgnorePointer(
        ignoring: true,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(isRemoving),
          tween: Tween(
            begin: isRemoving ? 1.0 : 0.0,
            end: isRemoving ? 0.0 : 1.0,
          ),
          duration: Duration(milliseconds: isRemoving ? 120 : 50),
          onEnd: () {
            if (isRemoving) {
              overlayEntry.remove();
            }
          },
          builder: (context, value, child) {
            return Align(
              alignment: MediaQuery.orientationOf(context) == .portrait
                  ? Alignment.bottomCenter
                  : Alignment.centerRight,
              child: Padding(
                padding: MediaQuery.orientationOf(context) == .portrait
                    ? const EdgeInsets.only(bottom: 52)
                    : const EdgeInsets.only(right: 92),
                child: Opacity(
                  opacity: value,
                  child: Image.asset(
                    isCorrect ? 'assets/correct.png' : 'assets/incorrect.png',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 300), () {
      isRemoving = true;
      overlayEntry.markNeedsBuild();
    });
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
      // Main keypad
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildKeyRow(['7', '8', '9'])),
                const SizedBox(height: 6),
                Expanded(child: _buildKeyRow(['4', '5', '6'])),
                const SizedBox(height: 6),
                Expanded(child: _buildKeyRow(['1', '2', '3'])),
                const SizedBox(height: 6),
                Expanded(child: _buildBottomRow(levelType)),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Delete button
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: ElevatedButton(
                      onPressed: onDeleteDigit,
                      onLongPress: onClearAll,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          double.infinity,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.backspace, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Check Button
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          double.infinity,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.check, size: 45),
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

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildKey(keys[0])),
        const SizedBox(width: 6),
        Expanded(child: _buildKey(keys[1])),
        const SizedBox(width: 6),
        Expanded(child: _buildKey(keys[2])),
      ],
    );
  }

  Widget _buildBottomRow(KeypadType type) {
    switch (type) {
      case .mitori:
        return Row(
          children: [
            Expanded(child: _buildKey('-')),
            const SizedBox(width: 6),
            Expanded(child: _buildKey('0')),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),

                child: ElevatedButton(
                  onPressed: () => onAppendDigit('a'),

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Transform.rotate(
                    angle: pi,
                    child: const Icon(Icons.start, size: 40),
                  ),
                ),
              ),
            ),
          ],
        );
      case .divMult:
        return Row(
          children: [
            Expanded(flex: 2, child: _buildKey('0')),
            const SizedBox(width: 6),
            Expanded(flex: 1, child: _buildKey('.')),
          ],
        );
      case .flash:
        return Row(
          children: [
            Expanded(flex: 2, child: _buildKey('0')),
            const SizedBox(width: 6),
            Expanded(flex: 1, child: _buildKey('-')),
          ],
        );
    }
  }

  Widget _buildKey(String value) {
    return Listener(
      onPointerDown: (event) => onAppendDigit(
        value,
      ), // registers on tap down instead of tap down and release
      child: ElevatedButton(
        onPressed: () => (),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, double.infinity),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 32, fontFamily: 'bizUDPGR'),
        ),
      ),
    );
  }
}

enum KeypadType { divMult, mitori, flash }
