import "dart:math";
import "../models/level_definitions.dart";

enum ProblemType { type1, type2, type3, type4, type5 }

class DivMultSpec {
  final int digitCount;
  final ProblemType problemType;
  final List<List<int>> split;

  const DivMultSpec({
    required this.digitCount,
    required this.problemType,
    required this.split,
  });
}

class DivMultProblemSet<TProblem> {
  final List<String> formattedProblems = [];
  final List<String> formattedAnswers = [];
  DivMultProblemSet({required DivMultLevel level}) {
    final rand = Random();

    for (Map batch in level.divMultSource.templates) {
      final int type2Count = batch['type2Count'] ?? 0;
      final int type3Count = batch['type3Count'] ?? 0;
      final int type4Count = batch['type4Count'] ?? 0;
      final int type5Count = batch['type5Count'] ?? 0;
      final int intRound =
          batch['intRound'] ??
          0; // marks if the answer should be rounded to the whole number. 1 is yes, 0 is no
      final int problemCount = batch['problemCount'] ?? 15;
      final int digits = batch['digits'];
      final List<List<int>> split = level.divMultSplit.templates[digits];

      final typeList = <ProblemType>[
        ...List.filled(type2Count, ProblemType.type2),
        ...List.filled(type3Count, ProblemType.type3),
        ...List.filled(type4Count, ProblemType.type4),
        ...List.filled(type5Count, ProblemType.type5),
      ];

      while (typeList.length < problemCount) {
        typeList.add(ProblemType.type1);
      }

      typeList.shuffle(rand);

      for (final type in typeList) {
        final DivMultSpec spec = DivMultSpec(
          problemType: type,
          digitCount: digits,
          split: split,
        );
        var fullProblem = level.builder(spec: spec);

        while (formattedAnswers.contains(fullProblem.formattedThird)) {
          fullProblem = level.builder(spec: spec);
        }

        // Only add if we found a unique answer
        if (!formattedAnswers.contains(fullProblem.formattedThird)) {
          formattedProblems.add(
            intRound == 1
                ? fullProblem.problemWithYenSymbol
                : fullProblem.problem,
          );
          formattedAnswers.add(fullProblem.formattedThird);
        }
      }
    }
  }
}
