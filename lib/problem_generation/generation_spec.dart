import "dart:math";
import "../models/divmult_difficulty.dart";
import "../models/sources.dart";

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

class FlashSpec {
  int probCount;
  int digitCount;
  int length;
  int time;
  String difficulty;
  bool allowMinus;
  bool digitAllDifferent;
  bool neverNegative;
  bool isExam;

  FlashSpec({
    this.allowMinus = false,
    this.difficulty = "random",
    this.digitAllDifferent = true,
    this.digitCount = 1,
    this.isExam = false,
    this.length = 8,
    this.time = 10,
    this.neverNegative = true,
    this.probCount = 15,
  });
}

FlashSpec getFlashSpec(String level, {Map<String, dynamic>? overrides}) {
  final baseConfig = flashSource[level] ?? {};
  final merged = {...baseConfig, ...?overrides};

  return FlashSpec(
    allowMinus: merged["allowMinus"] ?? false,
    difficulty: merged["difficulty"] ?? "normal",
    digitAllDifferent: merged["digitAllDifferent"] ?? false,
    digitCount: merged["digitCount"] ?? 1,
    isExam: merged["isExam"] ?? false,
    length: merged["length"] ?? 1,
    time: merged["time"] ?? 10,
    neverNegative: merged["neverNegative"] ?? false,
    probCount: merged["probCount"] ?? 0,
  );
}

class DivMultProblemSet<TProblem> {
  final formattedProblems = <String>[];
  final formattedAnswers = <String>[];
  DivMultProblemSet({required DivMultLevel level}) {
    final rand = Random();

    for (Map batch in level.divMultSource.templates) {
      final int type2Count = batch['type2Count'] ?? 0;
      final int type3Count = batch['type3Count'] ?? 0;
      final int type4Count = batch['type4Count'] ?? 0;
      final int type5Count = batch['type5Count'] ?? 0;
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
        formattedProblems.add(fullProblem.problem);
        formattedAnswers.add(fullProblem.formattedThird);
      }
    }
  }
}
