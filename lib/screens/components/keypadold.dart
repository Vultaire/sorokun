import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/helpers.dart';

class Keypad extends StatelessWidget {
  Keypad({super.key});

  final TextEditingController _controller = TextEditingController();
  String _internalString = '';
  String _formatted = '';
  String _beforeCaret = '';

  TextPainter? _textPainter;

  void _appendDigit(String digit) {
    String currentText = _controller.text.replaceAll(
      ',',
      '',
    ); // Remove existing commas

    // Check if we're trying to add a minus sign
    if (digit == '-') {
      // Only allow minus at the beginning and if there's no minus already
      if (!_internalString.startsWith('-')) {
        _internalString = '-$_internalString';
      } else if (_internalString.startsWith('-')) {
        // Remove minus if it's already there (toggle functionality)
        _internalString = _internalString.substring(1);
      }
    }
    // Check if we're trying to add a decimal point
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

    _formatted = formatWithCommas(result);
    int caretIndex = _formatted.indexOf('b');
    _beforeCaret = _formatted.substring(0, caretIndex);
  }

  void _deleteDigit() {
    if (_controller.text.isNotEmpty) {
      _internalString = _internalString.substring(
        0,
        _internalString.length - 1,
      );

      _updateText();
    }
  }

  void _updateText() {
    _makeFormatted();
    _controller.text = _formatted;
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
                          child: const Icon(Icons.backspace),
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
                          child: const Icon(Icons.home),
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
                  childAspectRatio: 2,
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
                margin: const EdgeInsets.only(top: 6),
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
