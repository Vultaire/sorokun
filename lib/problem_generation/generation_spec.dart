import "flash_source.dart";
import "paper_source.dart";

class DivisionSpec {
  int probCount;
  int digitCount;
  bool integerDividend;
  bool hasDecimals;
  bool isUnneat;
  bool controlDigitSplit;
  bool isExam;

  DivisionSpec({
    this.isExam = true,
    this.probCount = 15,
    this.digitCount = 6,
    this.integerDividend = false,
    this.hasDecimals = false,
    this.isUnneat = false,
    this.controlDigitSplit = true,
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

class MultiplicationSpec {
  int? probCount;
  int? digitCount;
  bool? integerDividend;
  bool? hasDecimals;
  bool? controlDigitSplit;
  bool? isExam;

  MultiplicationSpec({
    this.isExam,
    this.probCount,
    this.digitCount,
    this.integerDividend,
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
