import 'dart:math';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';

import '../../problem_generation/helpers.dart';
import '../paper_problem.dart';

mixin KeypadMethods<T extends StatefulWidget> on State<T> {
  List<TextFieldData> get textFieldDataList;
  int get currentIndex;
  CarouselSliderController get carouselController;
  List<String> get allAnswers;
  List<bool> get answerBools; //true = correct, false = incorrect
  bool get isExam;
  static final _digitsOnlyRegex = RegExp(r'[,.\-]');

  void appendDigit(String digit) {
    setState(() {
      final data = textFieldDataList[currentIndex];

      if (digit == '-') {
        if (!data.internalString.startsWith('-')) {
          data.internalString = '-${data.internalString}';
        } else {
          data.internalString = data.internalString.substring(1);
        }
      } else if (digit == '.') {
        if (!data.internalString.contains('.') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
        }
      } else if (digit == 'a') {
        if (!data.internalString.endsWith('a') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
        }
      } else {
        String digitsOnly = data.formatted.replaceAll(_digitsOnlyRegex, '');
        if (digitsOnly.length < 10) {
          data.internalString += digit;
        }
      }
      _updateText(data);
    });
  }

  void _updateText(TextFieldData data) {
    String result =
        '${data.internalString}b'; // 'b' marks the position of the caret
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
      });
    }
  }

  void clearAll() {
    setState(() {
      final data = textFieldDataList[currentIndex];
      data.internalString = '';
      _updateText(data);
    });
  }

  void submit() {
    if (textFieldDataList[currentIndex].internalString.isEmpty) {
      _handleEmptyAnswer();
      return;
    }
    if (!isExam && !_isAnswerCorrect()) {
      showResultPopup(context, false);
      return;
    }

    if (!isExam) {
      showResultPopup(context, true);
      _moveToNextEmptyQuestion();
    } else {
      _moveToNextEmptyQuestion();
    }
  }

  bool _isAnswerCorrect() {
    final isCorrect =
        textFieldDataList[currentIndex].formatted == allAnswers[currentIndex];
    answerBools[currentIndex] = isCorrect;
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
  }

  void _handleEmptyAnswer() {
    // TODO: Add error sound
  }

  void _handleAllQuestionsAnswered() {
    // TODO: Add scoring callback
  }

  void showResultPopup(BuildContext context, bool isCorrect) {
    late OverlayEntry overlayEntry;
    bool isRemoving = false;

    overlayEntry = OverlayEntry(
      builder: (context) => TweenAnimationBuilder<double>(
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
            alignment:
                Alignment.bottomCenter, // Adjust this for keypad position
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30), // Adjust offset
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
  });

  final void Function(String) onAppendDigit;
  final VoidCallback onDeleteDigit;
  final VoidCallback onClearAll;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),

        child: Column(
          children: [
            // Top row - backspace and home
            Container(
              margin: const EdgeInsets.only(bottom: 6),

              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: ElevatedButton(
                        onPressed: onClearAll,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Icon(Icons.clear, size: 45),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),

                      child: ElevatedButton(
                        onPressed: () => onAppendDigit('a'),

                        style: ElevatedButton.styleFrom(
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
              ),
            ),

            // Main keypad
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildKeyRow(['7', '8', '9'])),
                        const SizedBox(height: 6),
                        Expanded(child: _buildKeyRow(['4', '5', '6'])),
                        const SizedBox(height: 6),
                        Expanded(child: _buildKeyRow(['1', '2', '3'])),
                        const SizedBox(height: 6),
                        Expanded(child: _buildKeyRow(['-', '0', '.'])),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Delete button
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 80),
                          child: ElevatedButton(
                            onPressed: onDeleteDigit,
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
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildKey(String value) {
    return ElevatedButton(
      onPressed: () => onAppendDigit(value),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, double.infinity),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 32, fontFamily: 'bizUDPGR'),
      ),
    );
  }
}
