import 'dart:math';

import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/helpers.dart';

class Keypad extends StatefulWidget {
  Keypad({super.key, required this.controller, required this.onCaretChanged});

  final TextEditingController controller;
  final void Function(double) onCaretChanged;

  @override
  State<Keypad> createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  String _internalString = '';

  String _formatted = '';

  String _beforeCaret = '';

  TextPainter? _textPainter;

  void _appendDigit(String digit) {
    setState(() {
      String currentText = widget.controller.text.replaceAll(',', '');

      // minus sign
      if (digit == '-') {
        // Only allow minus at the beginning and if there's no minus already
        if (!_internalString.startsWith('-')) {
          _internalString = '-$_internalString';
        } else if (_internalString.startsWith('-')) {
          // Remove minus if it's already there (toggle functionality)
          _internalString = _internalString.substring(1);
        }
      }
      // decimal point
      else if (digit == '.') {
        if (!_internalString.contains('.') &&
            _internalString.isNotEmpty &&
            _internalString != '-') {
          _internalString += digit;
        }
      } else {
        _internalString += digit;
      }

      // Check length limit (excluding commas, decimal point, and minus for counting)
      String digitsOnly = currentText.replaceAll(RegExp(r'[,.\-]'), '');
      if (digitsOnly.length > 15) {
        return; // Limit to 15 digits (excluding formatting)
      }

      _updateText();
    });
  }

  void _makeFormatted() {
    String result = '${_internalString}b';
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
    _formatted = formattedWithPlaceholder.replaceAll('b', '');
    _beforeCaret = _formatted.substring(0, caretIndex);
  }

  void _getCaretPosition() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: _beforeCaret,
        style: const TextStyle(
          fontSize: 17.8,
          fontFamily: 'abacusFont',
        ), // I have no idea why I have to use 17.8 instead of 17 here for the caret to line up correctly
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter!.layout();
    final pos = _textPainter!.width;

    widget.onCaretChanged(pos);
  }

  void _deleteDigit() {
    if (widget.controller.text.isNotEmpty) {
      _internalString = _internalString.substring(
        0,
        _internalString.length - 1,
      );

      _updateText();
    }
  }

  void _updateText() {
    _makeFormatted();
    widget.controller.text = _formatted;
    _getCaretPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
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
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: ElevatedButton(
                          onPressed: () => _deleteDigit(),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.backspace, size: 25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: ElevatedButton(
                          onPressed: () => _appendDigit('a'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Transform.rotate(
                            angle: pi, // radians; 90° clockwise
                            child: const Icon(Icons.start, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main keypad
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.5,
                  children: [
                    _buildKey('7'),
                    _buildKey('8'),
                    _buildKey('9'),
                    _buildKey('4'),
                    _buildKey('5'),
                    _buildKey('6'),
                    _buildKey('1'),
                    _buildKey('2'),
                    _buildKey('3'),
                    _buildKey('-'),
                    _buildKey('0'),
                    _buildKey('.'),
                  ],
                ),
              ),

              // Bottom check button
              Container(
                margin: const EdgeInsets.only(top: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.check),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      child: ElevatedButton(
        onPressed: () => _appendDigit(value),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(value, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
