import 'dart:math';
import 'package:flutter/material.dart';

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

                        child: const Icon(Icons.clear, size: 25),
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
                            child: const Icon(Icons.backspace, size: 25),
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
                            child: const Icon(Icons.check, size: 25),
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
      child: Text(value, style: const TextStyle(fontSize: 32)),
    );
  }
}
