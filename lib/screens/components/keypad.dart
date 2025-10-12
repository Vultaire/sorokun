import 'package:flutter/material.dart';

class Keypadold extends StatelessWidget {
  final void Function(String) onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onCheck;
  final VoidCallback onHome;

  const Keypadold({
    Key? key,
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onCheck,
    required this.onHome,
  }) : super(key: key);

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
                          onPressed: onBackspace,
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
                          onPressed: onHome,
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
                          onPressed: onCheck,
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
        onPressed: () => onDigitPressed(value),
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
