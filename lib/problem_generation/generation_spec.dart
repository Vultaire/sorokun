import "flash_source.dart";
import "paper_source.dart";
import "dart:math";

typedef ProblemBuilder<TProblem, TSpec> =
    TProblem Function(TSpec spec, ProblemType type);

class DivisionSpec {
  int probCount;
  int digitCount;
  bool integerDividend;
  bool integerDivisor;
  bool isUnneat;
  bool isExam;
  String difficulty;

  DivisionSpec({
    this.isExam = true,
    this.difficulty = "5kyuu",
    this.probCount = 15,
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
      probCount: probCount,
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
  int probCount;
  int digitCount;
  bool integerMultiplicand;
  bool integerMultiplier;
  bool isExam;
  bool maySwap;
  String difficulty;

  MultiplicationSpec({
    this.isExam = true,
    this.difficulty = "5kyuu",
    this.probCount = 15,
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
      probCount: probCount,
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
      // not applicable to multiplication
      throw ArgumentError(
        'ProblemType.type5 is not valid for MultiplicationSpec',
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
  List<Map<String, dynamic>> problemSpec;

  PaperSpec({this.isExam = true, required this.problemSpec});
}

PaperSpec getPaperSpec(String level, {List<Map<String, dynamic>>? overrides}) {
  final baseConfig = List<Map<String, dynamic>>.from(paperSource[level] ?? []);
  final merged = [...baseConfig, ...?overrides];

  return PaperSpec(isExam: true, problemSpec: merged);
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
  final Map<String, Map<String, int>> source;

  ProblemSet({required this.builder, required this.source});

  List<TProblem> generateProblems({required TSpec base}) {
    final problems = <TProblem>[];

    const int firstPartCount = 7;
    const int secondPartCount = 8;

    final config = source[(base as dynamic).difficulty] ?? source['noDecimal']!;

    final type2Count = config['type2Count']!;
    final type3Count = config['type3Count'];
    final type4Count = config['type4Count']!;
    final type5Count = config['type5Count']!;

    // --- First part ---
    problems.add(builder(base, ProblemType.type1));

    final firstPartPool = <ProblemType>[
      ...List.filled(type2Count, ProblemType.type2),
      if (type3Count != null) ...List.filled(type3Count, ProblemType.type3),
    ];

    while (firstPartPool.length < firstPartCount - 1) {
      firstPartPool.add(ProblemType.type1);
    }
    firstPartPool.shuffle(_rand);

    for (final type in firstPartPool) {
      problems.add(builder(base, type));
    }

    // --- Second part ---
    problems.add(builder(base, ProblemType.type1));

    final secondPartPool = <ProblemType>[
      ...List.filled(type4Count, ProblemType.type4),
      ...List.filled(type5Count, ProblemType.type5),
    ];

    while (secondPartPool.length < secondPartCount - 1) {
      secondPartPool.add(ProblemType.type1);
    }
    secondPartPool.shuffle(_rand);

    for (final type in secondPartPool) {
      problems.add(builder(base, type));
    }

    return problems;
  }
}
