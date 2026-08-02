import 'package:flutter/material.dart';

class MitoriDisplay extends StatelessWidget {
  const MitoriDisplay({
    super.key,
    this.problemIndex,
    required this.currentProblem,
    required this.isSimpleMitori,
  });

  final int? problemIndex;
  final List<String> currentProblem;
  final bool isSimpleMitori;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (problemIndex case final index?)
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'mPlus',
                  fontWeight: FontWeight.bold,
                ),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3.0,
                    horizontal: 10.0,
                  ),
                  child: Text(
                    currentProblem[0],
                    style: switch (isSimpleMitori) {
                      true => const TextStyle(
                        fontSize: 140,
                        fontFamily: 'ogutama',
                      ),
                      false => const TextStyle(
                        fontSize: 30,
                        fontFamily: 'abacusFontSpaced',
                      ),
                    },
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ],
            ),
            ...currentProblem
                .sublist(1)
                .map(
                  (n) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3.0,
                      horizontal: 10.0,
                    ),
                    child: Text(
                      n,
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'abacusFontSpaced',
                      ),
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
