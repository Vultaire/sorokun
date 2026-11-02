// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

class DivMultDisplay extends StatelessWidget {
  const DivMultDisplay({
    super.key,
    required this.problemIndex,
    required this.isFocused,
    required this.underEquals,
    required this.intRoundIndex,
    required this.currentProblem,
  });
  final int problemIndex;
  final bool isFocused;
  final Widget underEquals;
  final int intRoundIndex;
  final String currentProblem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decimal Rounding Notice
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            opacity: (problemIndex == 0 && intRoundIndex != -1 && isFocused)
                ? 1.0
                : 0.0,
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Text(
                AppLocalizations.of(context).roundingDecimalNotice,
                style: TextStyle(fontSize: 18, fontFamily: 'mPlus'),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        ),

        // Integer Rounding Notice
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            opacity: (problemIndex == intRoundIndex && isFocused) ? 1.0 : 0.0,
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Text(
                AppLocalizations.of(context).roundingIntegerNotice,
                style: TextStyle(fontSize: 18, fontFamily: 'mPlus'),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        ),

        Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  margin: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${problemIndex + 1}',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'mPlus',
                        fontWeight: .bold,
                      ),
                      textScaler: .noScaling,
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: .contain,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        currentProblem,
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'abacusFont',
                        ),
                        textScaler: .noScaling,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '||',
                      style: TextStyle(fontSize: 26),
                      textScaler: .noScaling,
                    ),
                    underEquals,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
