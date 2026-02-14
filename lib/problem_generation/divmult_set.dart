import "dart:math";
import "../models/level_definitions.dart";

enum ProblemType { type1, type2, type3, type4, type5, type6 }

abstract class DivMultProblem {
  String get formattedThird;
  String get problem;
}

class DivMultSpec {
  final int digitCount;
  final ProblemType problemType;
  final List<int> split;
  final bool intRound;

  const DivMultSpec({
    required this.digitCount,
    required this.problemType,
    required this.split,
    required this.intRound,
  });
}

class DivMultProblemSet {
  final List<DivMultProblem> fullProblemSet = [];
  DivMultProblemSet({required DivMultLevel level}) {
    final rand = Random();

    for (Map batch in level.divMultSource.templates) {
      final int type2Count = batch['type2Count'] ?? 0;
      final int type3Count = batch['type3Count'] ?? 0;
      final int type4Count = batch['type4Count'] ?? 0;
      final int type5Count = batch['type5Count'] ?? 0;
      final int type6Count = batch['type6Count'] ?? 0;
      final bool intRound =
          batch['intRound'] ??
          false; // marks if the answer should be rounded to the whole number.
      final int problemCount = batch['problemCount'] ?? 15;
      final int digits = batch['digits'];
      final List<int> splitCounts = batch['splitCount'] ?? [15];
      final List<List<int>> split = level.divMultSplit.templates[digits];

      final typeList = <ProblemType>[
        ...List.filled(type2Count, ProblemType.type2),
        ...List.filled(type3Count, ProblemType.type3),
        ...List.filled(type4Count, ProblemType.type4),
        ...List.filled(type5Count, ProblemType.type5),
        ...List.filled(type6Count, ProblemType.type6),
      ];

      while (typeList.length < problemCount) {
        typeList.add(ProblemType.type1);
      }

      typeList.shuffle(rand);

      final List<DivMultProblem> problemsInBatch = [];

      int typeIndex = 0;

      for (var splitIndex = 0; splitIndex < splitCounts.length; splitIndex++) {
        for (
          var remaining = splitCounts[splitIndex];
          remaining > 0;
          remaining--
        ) {
          final type = typeList[typeIndex++];

          final DivMultSpec spec = DivMultSpec(
            problemType: type,
            digitCount: digits,
            split: split[splitIndex],
            intRound: intRound,
          );

          var fullProblem = level.builder(spec: spec);

          while (formattedAnswers.contains(fullProblem.formattedThird)) {
            fullProblem = level.builder(spec: spec);
          }

          problemsInBatch.add(fullProblem);
          formattedAnswers.add(fullProblem.formattedThird);
        }
      }

      problemsInBatch.shuffle(rand);
      fullProblemSet.addAll(problemsInBatch);
    }
  }
  List<String> get formattedAnswers =>
      fullProblemSet.map((p) => p.formattedThird).toList();

  List<String> get formattedProblems =>
      fullProblemSet.map((p) => p.problem).toList();
}
