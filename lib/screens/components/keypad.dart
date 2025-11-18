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
      if (digit == '-') {
        // minus sign

        // Only allow minus at the beginning and if there's no minus already

        if (!_internalString.startsWith('-')) {
          _internalString = '-$_internalString';
        } else if (_internalString.startsWith('-')) {
          // Remove minus if it's already there (toggle functionality)

          _internalString = _internalString.substring(1);
        }
      } else if (digit == '.') {
        // decimal point

        if (!_internalString.contains('.') &&
            _internalString.isNotEmpty &&
            _internalString != '-') {
          _internalString += digit;
        }
      } else if (digit == 'a') {
        if (!_internalString.endsWith('a') &&
            _internalString.isNotEmpty &&
            _internalString != '-') {
          _internalString += digit;
        }
      } else {
        String digitsOnly = widget.controller.text.replaceAll(
          RegExp(r'[,.\-]'),

          '',
        );

        if (digitsOnly.length < 16) {
          _internalString += digit;
        }
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

        style: const TextStyle(fontSize: 17, fontFamily: 'abacusFontSpaced'),
      ),

      textDirection: TextDirection.ltr,
    );

    _textPainter!.layout();

    final pos = _textPainter!.width + 3;

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // Main keypad (inside the main outer Row)
                    Expanded(
                      // This Column replaces your Table structure
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ROW 1
                          Expanded(child: _buildKeyRow(['7', '8', '9'])),
                          const SizedBox(height: 6), // Vertical spacing
                          // ROW 2
                          Expanded(child: _buildKeyRow(['4', '5', '6'])),
                          const SizedBox(height: 6),
                          // ROW 3
                          Expanded(child: _buildKeyRow(['1', '2', '3'])),
                          const SizedBox(height: 6),
                          // ROW 4
                          Expanded(child: _buildKeyRow(['-', '0', '.'])),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Check button
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 120),

                            child: ElevatedButton(
                              onPressed: () {},

                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                  double.infinity,
                                  double.infinity,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              child: const Icon(Icons.check),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 120),

                            child: ElevatedButton(
                              onPressed: () {},

                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                  double.infinity,
                                  double.infinity,
                                ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildKey(keys[0])),
        const SizedBox(width: 6), // Horizontal spacing
        Expanded(child: _buildKey(keys[1])),
        const SizedBox(width: 6),
        Expanded(child: _buildKey(keys[2])),
      ],
    );
  }

  Widget _buildKey(String value) {
    return ElevatedButton(
      onPressed: () => _appendDigit(value),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, double.infinity),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(value, style: const TextStyle(fontSize: 24)),
    );
  }
}
