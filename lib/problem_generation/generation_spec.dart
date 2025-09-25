import "flash_source.dart";
import "paper_source.dart";
import "dart:math";

typedef ProblemBuilder<TProblem, TSpec> =
    TProblem Function(TSpec spec, ProblemType type);

class DivisionSpec {
  int digitCount;
  bool integerDividend;
  bool integerDivisor;
  bool isUnneat;
  bool isExam;
  String difficulty;

  DivisionSpec({
    this.isExam = true,
    this.difficulty = "5kyuu",
    this.digitCount = 6,
    this.integerDividend = false,
    this.integerDivisor = false,
    this.isUnneat = false,
  });

  DivisionSpec copyWith({
    bool? integerDividend,
    bool? integerDivisor,
    bool? isUnneat,
  }) {
    return DivisionSpec(
      digitCount: digitCount,
      difficulty: difficulty,
      integerDividend: integerDividend ?? this.integerDividend,
      integerDivisor: integerDivisor ?? this.integerDivisor,
      isUnneat: isUnneat ?? this.isUnneat,
    );
  }
}

enum ProblemType { type1, type2, type3, type4, type5 }

DivisionSpec divSpecFromType(DivisionSpec base, ProblemType type) {
  switch (type) {
    case ProblemType.type1:
      return base.copyWith(
        integerDividend: true,
        integerDivisor: true,
        isUnneat: false,
      );
    case ProblemType.type2:
      return base.copyWith(
        integerDividend: false,
        integerDivisor: false,
        isUnneat: false,
      );
    case ProblemType.type3:
      return base.copyWith(
        integerDividend: false,
        integerDivisor: false,
        isUnneat: true,
      );
    case ProblemType.type4:
      return base.copyWith(
        integerDividend: true,
        integerDivisor: false,
        isUnneat: false,
      );
    case ProblemType.type5:
      return base.copyWith(
        integerDividend: true,
        integerDivisor: false,
        isUnneat: true,
      );
  }
}

class MultiplicationSpec {
  int digitCount;
  bool integerMultiplicand;
  bool integerMultiplier;
  bool isExam;
  bool maySwap;
  String difficulty;

  MultiplicationSpec({
    this.isExam = true,
    this.difficulty = "5kyuu",
    this.digitCount = 6,
    this.integerMultiplicand = true,
    this.integerMultiplier = true,
    this.maySwap = false,
  });

  MultiplicationSpec copyWith({
    bool? integerMultiplicand,
    bool? integerMultiplier,
    bool? maySwap,
  }) {
    return MultiplicationSpec(
      digitCount: digitCount,
      difficulty: difficulty,
      integerMultiplicand: integerMultiplicand ?? this.integerMultiplicand,
      integerMultiplier: integerMultiplier ?? this.integerMultiplier,
      maySwap: maySwap ?? this.maySwap,
    );
  }
}

MultiplicationSpec multSpecFromType(MultiplicationSpec base, ProblemType type) {
  switch (type) {
    case ProblemType.type1:
      return base.copyWith(integerMultiplicand: true, integerMultiplier: true);
    case ProblemType.type2:
      return base.copyWith(
        integerMultiplicand: false,
        integerMultiplier: false,
      );
    case ProblemType.type3:
      throw ArgumentError(
        'ProblemType.type3 is not valid for MultiplicationSpec',
      );
    case ProblemType.type4:
      return base.copyWith(
        integerMultiplicand: true,
        integerMultiplier: false,
        maySwap: true,
      );
    case ProblemType.type5:
      return base.copyWith(
        integerMultiplicand: true,
        integerMultiplier: false,
        maySwap: false,
      );
  }
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

class PaperSpec {
  bool isExam;
  List<Map<String, dynamic>> source;

  PaperSpec({this.isExam = true, required this.source});
}

PaperSpec getPaperSpec(String level, {List<Map<String, dynamic>>? overrides}) {
  final baseConfig = List<Map<String, dynamic>>.from(paperSource[level] ?? []);
  final merged = [...baseConfig, ...?overrides];

  return PaperSpec(isExam: true, source: merged);
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

class ProblemSet<TProblem, TSpec> {
  final Random _rand = Random();
  final ProblemBuilder<TProblem, TSpec> builder;
  final Map<String, List<Map<String, dynamic>>> source;

  ProblemSet({required this.builder, required this.source});

  List<TProblem> generateProblems({required TSpec base}) {
    final problems = <TProblem>[];

    final batchList = source[(base as dynamic).difficulty];

    for (Map batch in batchList!) {
      final type2Count = batch["type2Count"] ?? 0;
      final type3Count = batch['type3Count'] ?? 0;
      final type4Count = batch['type4Count'] ?? 0;
      final type5Count = batch['type5Count'] ?? 0;
      final problemCount = batch['problemCount'] ?? 15;
      final digits = batch['digits'];

      final typeList = <ProblemType>[
        ...List.filled(type2Count, ProblemType.type2),
        ...List.filled(type3Count, ProblemType.type3),
        ...List.filled(type4Count, ProblemType.type4),
        ...List.filled(type5Count, ProblemType.type5),
      ];

      while (typeList.length < problemCount) {
        typeList.add(ProblemType.type1);
      }

      typeList.shuffle(_rand);

      final modifiedBase = (base as dynamic)..digitCount = digits;

      for (final type in typeList) {
        problems.add(builder(modifiedBase, type));
      }
    }
    return problems;
  }
}
