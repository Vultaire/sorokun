import "flash_source.dart";
import "paper_source.dart";

class DivisionSpec {
  int probCount;
  int digitCount;
  bool integerDividend;
  bool integerDivisor;
  bool isUnneat;
  bool controlDigitSplit;
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
    this.controlDigitSplit = true,
  });
}

enum ProblemType { type1, type2, type3, type4, type5 }

DivisionSpec specFromType(DivisionSpec base, ProblemType type) {
  switch (type) {
    case ProblemType.type1:
      return DivisionSpec(
        probCount: base.probCount,
        digitCount: base.digitCount,
        integerDividend: true,
        integerDivisor: true,
        isUnneat: false,
        controlDigitSplit: base.controlDigitSplit,
        isExam: base.isExam,
        difficulty: base.difficulty,
      );
    case ProblemType.type2:
      return DivisionSpec(
        probCount: base.probCount,
        digitCount: base.digitCount,
        integerDividend: false,
        integerDivisor: false,
        isUnneat: false,
        difficulty: base.difficulty,
      );
    case ProblemType.type3:
      return DivisionSpec(
        probCount: base.probCount,
        digitCount: base.digitCount,
        integerDividend: false,
        integerDivisor: false,
        isUnneat: true,
        difficulty: base.difficulty,
      );
    case ProblemType.type4:
      return DivisionSpec(
        probCount: base.probCount,
        digitCount: base.digitCount,
        integerDividend: true,
        integerDivisor: false,
        isUnneat: false,
        difficulty: base.difficulty,
      );
    case ProblemType.type5:
      return DivisionSpec(
        probCount: base.probCount,
        digitCount: base.digitCount,
        integerDividend: true,
        integerDivisor: false,
        isUnneat: true,
        difficulty: base.difficulty,
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

class MultiplicationSpec {
  int? probCount;
  int? digitCount;
  bool? decimalOverInteger;
  bool? hasDecimals;
  bool? controlDigitSplit;
  bool? isExam;

  MultiplicationSpec({
    this.isExam,
    this.probCount,
    this.digitCount,
    this.decimalOverInteger,
    this.hasDecimals,
    this.controlDigitSplit,
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

DivisionSpec getDivisionSpec(String level, {Map<String, dynamic>? overrides}) {
  final baseConfig = flashSource[level] ?? {};
  final merged = {...baseConfig, ...?overrides};

  return DivisionSpec();
}

//final spec2 = getFlashSpec("19kyuu", overrides: {
//  "length": 5,
//  "allowMinus": false,
//});
