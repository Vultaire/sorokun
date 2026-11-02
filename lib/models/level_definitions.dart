// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:soroban_app/models/divmult_source.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

part 'flash_source.dart';

enum DivMultLevel implements PaperProblemLevel {
  zsmk9(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.zsk9,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmk8(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.zsk8,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmk7(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.zsk7,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmk6(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.zsk6,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmak5(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.zsak5,
    levelInfo: .zsa,
    builder: MultiplicationProblem.new,
  ),
  zsmk5(
    split: .sixDigit,
    divMultSource: MultiplicationSource.zsk5,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmak4(
    split: .threeAndFourB,
    divMultSource: MultiplicationSource.zsak4,
    levelInfo: .zsa,
    builder: MultiplicationProblem.new,
  ),
  zsmk4(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.zsk4,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmak3(
    split: .fourSpecialB,
    divMultSource: MultiplicationSource.zsak3,
    levelInfo: .zsa,
    builder: MultiplicationProblem.new,
  ),
  zsmk3(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.zsk3,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmak2(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.zsak2,
    levelInfo: .zsa,
    builder: MultiplicationProblem.new,
  ),
  zsmk2(
    split: .eightDigit,
    divMultSource: MultiplicationSource.zsk2,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmak1(
    split: .fourAndFive,
    divMultSource: MultiplicationSource.zsak1,
    levelInfo: .zsa,
    builder: MultiplicationProblem.new,
  ),
  zsmk1(
    split: .nineDigit,
    divMultSource: MultiplicationSource.zsk1,
    levelInfo: .zs,
    builder: MultiplicationProblem.new,
  ),
  zsmdan(
    split: .zsmdan,
    divMultSource: MultiplicationSource.zsdan,
    levelInfo: .zsdan,
    builder: MultiplicationProblem.new,
  ),
  zsmadan(
    split: .fourToEight,
    divMultSource: MultiplicationSource.zsadan,
    levelInfo: .zsadan,
    builder: MultiplicationProblem.new,
  ),
  zsdk8(
    split: .threeDigitB,
    divMultSource: DivisionSource.zsk8,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdk7(
    split: .fourDigitC,
    divMultSource: DivisionSource.zsk7,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdk6(
    split: .fourDigitB,
    divMultSource: DivisionSource.zsk6,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdak5(
    split: .threeDigitB,
    divMultSource: DivisionSource.zsak5,
    levelInfo: .zsa,
    builder: DivisionProblem.new,
  ),
  zsdk5(
    split: .fiveDigit,
    divMultSource: DivisionSource.zsk5,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdak4(
    split: .threeAndFourA,
    divMultSource: DivisionSource.zsak4,
    levelInfo: .zsa,
    builder: DivisionProblem.new,
  ),
  zsdk4(
    split: .sixDigit,
    divMultSource: DivisionSource.zsk4,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdak3(
    split: .fourSpecialA,
    divMultSource: DivisionSource.zsak3,
    levelInfo: .zsa,
    builder: DivisionProblem.new,
  ),
  zsdk3(
    split: .sixDigit,
    divMultSource: DivisionSource.zsk3,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdak2(
    split: .fourDigitB,
    divMultSource: DivisionSource.zsak2,
    levelInfo: .zsa,
    builder: DivisionProblem.new,
  ),
  zsdk2(
    split: .sevenDigit,
    divMultSource: DivisionSource.zsk2,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdak1(
    split: .fourAndFive,
    divMultSource: DivisionSource.zsak1,
    levelInfo: .zsa,
    builder: DivisionProblem.new,
  ),
  zsdk1(
    split: .eightDigit,
    divMultSource: DivisionSource.zsk1,
    levelInfo: .zs,
    builder: DivisionProblem.new,
  ),
  zsdadan(
    split: .fourToEight,
    divMultSource: DivisionSource.zsadan,
    levelInfo: .zsadan,
    builder: DivisionProblem.new,
  ),
  zsddan(
    split: .zsddan,
    divMultSource: DivisionSource.zsdan,
    levelInfo: .zsdan,
    builder: DivisionProblem.new,
  ),
  nsmk10(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.nsk9,
    levelInfo: .nsk10Mult,
    builder: MultiplicationProblem.new,
  ),
  nsmk9(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.nsk9,
    levelInfo: .nsk9Mult,
    builder: MultiplicationProblem.new,
  ),
  nsmk8(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.nsk8,
    levelInfo: .nsk8To7DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk7(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.nsk7,
    levelInfo: .nsk8To7DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk6(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.nsk6,
    levelInfo: .nsk6To4DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk5(
    split: .sixDigit,
    divMultSource: MultiplicationSource.nsk5,
    levelInfo: .nsk6To4DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk4(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.nsk4,
    levelInfo: .nsk6To4DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmkj3(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nskj3,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk3(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nsk3,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmkj2(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nskj2,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk2(
    split: .nineDigit,
    divMultSource: MultiplicationSource.nsk2,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmkj1(
    split: .tenDigit,
    divMultSource: MultiplicationSource.nskj1,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmk1(
    split: .elevenDigit,
    divMultSource: MultiplicationSource.nsk1,
    levelInfo: .nsk3To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmdan(
    split: .elevenDigit,
    divMultSource: MultiplicationSource.nsdan,
    levelInfo: .nsdanDivMult,
    builder: MultiplicationProblem.new,
  ),
  nsdk8(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsk8,
    levelInfo: .nsk8To7DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk7(
    split: .fourDigitC,
    divMultSource: DivisionSource.nsk7,
    levelInfo: .nsk8To7DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk6(
    split: .fourDigitB,
    divMultSource: DivisionSource.nsk6,
    levelInfo: .nsk6To4DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk5(
    split: .fiveDigit,
    divMultSource: DivisionSource.nsk5,
    levelInfo: .nsk6To4DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk4(
    split: .sixDigit,
    divMultSource: DivisionSource.nsk4,
    levelInfo: .nsk6To4DivMult,
    builder: DivisionProblem.new,
  ),
  nsdkj3(
    split: .sixDigit,
    divMultSource: DivisionSource.nsjk3,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk3(
    split: .sixDigit,
    divMultSource: DivisionSource.nsk3,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdkj2(
    split: .sevenDigit,
    divMultSource: DivisionSource.nsjk2,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk2(
    split: .eightDigit,
    divMultSource: DivisionSource.nsk2,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdkj1(
    split: .nineDigit,
    divMultSource: DivisionSource.nsjk1,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdk1(
    split: .tenDigit,
    divMultSource: DivisionSource.nsk1,
    levelInfo: .nsk3To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsddan(
    split: .tenDigit,
    divMultSource: DivisionSource.nsdan,
    levelInfo: .nsdanDivMult,
    builder: DivisionProblem.new,
  ),
  nsdak6(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdak5(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdak4(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdakj3(
    split: .threeAndFourA,
    divMultSource: DivisionSource.nsajk3,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdak3(
    split: .fourDigitC,
    divMultSource: DivisionSource.nsak3,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdakj2(
    split: .fourSpecialA,
    divMultSource: DivisionSource.nsakj2,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdak2(
    split: .fourDigitB,
    divMultSource: DivisionSource.nsak2,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdakj1(
    split: .fourAndFive,
    divMultSource: DivisionSource.nsakj1,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdak1(
    split: .fiveDigit,
    divMultSource: DivisionSource.nsak1,
    levelInfo: .nsak6To1DivMult,
    builder: DivisionProblem.new,
  ),
  nsdadan(
    split: .nsadan,
    divMultSource: DivisionSource.nsadan,
    levelInfo: .nsadanDivMult,
    builder: DivisionProblem.new,
  ),
  nsmak4(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.nsak4, // sic
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmakj3(
    split: .threeAndFourB,
    divMultSource: MultiplicationSource.nsakj3,
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmak3(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.nsak2, // sic
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmakj2(
    split: .fourSpecialB,
    divMultSource: MultiplicationSource.nsakj2,
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmak2(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.nsak2,
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmakj1(
    split: .fourAndFive,
    divMultSource: MultiplicationSource.nsakj1,
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmak1(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.nsak1,
    levelInfo: .nsak6To1DivMult,
    builder: MultiplicationProblem.new,
  ),
  nsmadan(
    split: .nsadan,
    divMultSource: MultiplicationSource.nsadan,
    levelInfo: .nsadanDivMult,
    builder: MultiplicationProblem.new,
  );

  const DivMultLevel({
    required this.split,
    required this.divMultSource,
    required this.levelInfo,
    required this.builder,
  });
  final Split split;
  final DivMultSource divMultSource;
  @override
  final LevelInfo levelInfo;
  final Function builder;
  @override
  Set<int>? get letterCounts => null;
  @override
  int get problemCount => divMultSource.templates.fold(
    0,
    (sum, map) => sum + (map['problemCount'] as int),
  );
  @override
  Set<int> get houshouJippou => divMultSource.templates
      .map((map) => map['digits'] as int)
      .where((digits) => digits != 0)
      .toSet();
  @override
  int get maxDigits => 0;
}

enum ComplexMitoriLevel implements MitoriLevel {
  zsk10a(
    templates: [
      [
        {"digits": 1, "count": 6},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk10b(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 2},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk9(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 3},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk8(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),

  zsk7(
    templates: [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 2},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk6(
    templates: [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 5},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk5(
    templates: [
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 3},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk4(
    templates: [
      [
        {"digits": 3, "count": 2},
        {"digits": 4, "count": 3},
        {"digits": 5, "count": 2},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 2,
    levelInfo: .zs,
    problemCountPerTemplate: [5],
    repeat: 3,
    neverNegative: true,
  ),
  zsk3(
    templates: [
      [
        {"digits": 3, "count": 3},
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 3},
      ],
      [
        {"digits": 4, "count": 8},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 1,
    levelInfo: .zs,
    problemCountPerTemplate: [3, 2],
    repeat: 3,
    neverNegative: true,
  ),
  zsk2(
    templates: [
      [
        {"digits": 4, "count": 4},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 2},
      ],
      [
        {'digits': 4, 'count': 2},
        {'digits': 5, 'count': 6},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 1,
    levelInfo: .zs,
    problemCountPerTemplate: [3, 2],
    repeat: 3,
    neverNegative: false,
  ),
  zsk1(
    templates: [
      [
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 2},
        {"digits": 7, "count": 2},
      ],
      [
        {'digits': 5, 'count': 4},
        {'digits': 6, 'count': 4},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 1,
    levelInfo: .zs,
    problemCountPerTemplate: [3, 2],
    repeat: 3,
    neverNegative: false,
  ),
  zsdan(
    templates: [
      [
        {"digits": 3, "count": 3},
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 3},
      ],
      [
        {"digits": 4, "count": 3},
        {"digits": 5, "count": 4},
        {"digits": 6, "count": 3},
      ],
      [
        {"digits": 4, "count": 3},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 2},
        {"digits": 7, "count": 3},
      ],
      [
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 2},
        {"digits": 7, "count": 2},
        {"digits": 8, "count": 2},
      ],
      [
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 1},
        {"digits": 7, "count": 1},
        {"digits": 8, "count": 2},
        {"digits": 9, "count": 2},
      ],
      [
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 2},
        {"digits": 6, "count": 1},
        {"digits": 7, "count": 1},
        {"digits": 8, "count": 2},
        {"digits": 9, "count": 2},
      ],
    ],
    minusCount: 3,
    minusProblemsPerTemplate: 2,
    levelInfo: .zsdan,
    problemCountPerTemplate: [5, 5, 5, 5, 5, 5],
    repeat: 1,
    neverNegative: false,
  ),
  zsak7(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 1},
      ],
    ],
    minusCount: 0,
    minusProblemsPerTemplate: 0,
    levelInfo: .zsa,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  zsak6(
    templates: [
      [
        {"digits": 1, "count": 1},
        {"digits": 2, "count": 2},
      ],
    ],
    minusCount: 0,
    minusProblemsPerTemplate: 0,
    levelInfo: .zsa,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  zsak5(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 2},
      ],
      [
        {"digits": 2, "count": 3},
      ],
    ],
    minusCount: 0,
    minusProblemsPerTemplate: 0,
    levelInfo: .zsa,
    problemCountPerTemplate: [10, 10],
    repeat: 1,
  ),
  zsak4(
    templates: [
      [
        {"digits": 2, "count": 4},
      ],
    ],
    minusCount: 0,
    minusProblemsPerTemplate: 0,
    levelInfo: .zsa,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  zsak3(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 0,
    minusProblemsPerTemplate: 0,
    levelInfo: .zsa,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  zsak2(
    templates: [
      [
        {"digits": 2, "count": 3},
        {"digits": 3, "count": 2},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zsa,
    problemCountPerTemplate: [5],
    repeat: 4,
    neverNegative: true,
  ),
  zsak1(
    templates: [
      [
        {"digits": 3, "count": 5},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    levelInfo: .zsa,
    problemCountPerTemplate: [5],
    repeat: 4,
    neverNegative: true,
  ),
  zsadan(
    templates: [
      [
        {"digits": 3, "count": 5},
      ],
      [
        {"digits": 3, "count": 5},
      ],
      [
        {"digits": 3, "count": 3},
        {"digits": 4, "count": 2},
      ],
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 2},
      ],
      [
        {"digits": 3, "count": 3},
        {"digits": 4, "count": 3},
      ],
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 3},
      ],
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 4},
      ],
      [
        {"digits": 3, "count": 2},
        {"digits": 4, "count": 3},
        {"digits": 5, "count": 3},
      ],
    ],
    minusCount: 2, //actually starts with 2 minus
    minusCountPerGroup: [2, 2, 2, 2, 2, 3, 3, 3],
    minusProblemsPerTemplate: 2,
    levelInfo: .zsadan,
    problemCountPerTemplate: [4, 4, 7, 5, 5, 5, 5, 5],
    repeat: 1,
    neverNegative: true,
  ),
  nsk10(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 1,
    levelInfo: .nsk10Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk9(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 1,
    levelInfo: .nsk9To7Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk8(
    templates: [
      [
        {"digits": 2, "count": 8},
      ],
    ],
    minusCount: 2,
    levelInfo: .nsk9To7Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk7(
    templates: [
      [
        {"digits": 2, "count": 10},
      ],
    ],
    minusCount: 3,
    levelInfo: .nsk9To7Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk6(
    templates: [
      [
        {"digits": 3, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk6To4Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk5(
    templates: [
      [
        {"digits": 4, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk6To4Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk4(
    templates: [
      [
        {"digits": 5, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk6To4Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nskj3(
    templates: [
      [
        {"digits": 5, "count": 10},
      ],
      [
        {"digits": 6, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [5, 5],
    repeat: 1,
  ),
  nsk3(
    templates: [
      [
        {"digits": 6, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nskj2(
    templates: [
      [
        {"digits": 7, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk2(
    templates: [
      [
        {"digits": 8, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nskj1(
    templates: [
      [
        {"digits": 9, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsk1(
    templates: [
      [
        {"digits": 10, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsk3To1Mitori,
    problemCountPerTemplate: [10],
    repeat: 1,
  ),
  nsdan(
    templates: [
      [
        {"digits": 10, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsdanMitori,
    problemCountPerTemplate: [30],
    repeat: 1,
  ),
  nsak10(
    templates: [
      [
        {"digits": 1, "count": 3},
      ],
      [
        {"digits": 1, "count": 4},
      ],
      [
        {"digits": 1, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak10Mitori,
    problemCountPerTemplate: [15, 15, 20],
    repeat: 1,
  ),
  nsak9(
    templates: [
      [
        {"digits": 1, "count": 3},
      ],
      [
        {"digits": 1, "count": 4},
      ],
      [
        {"digits": 1, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak9Mitori,
    problemCountPerTemplate: [15, 15, 20],
    repeat: 1,
  ),
  nsak8(
    templates: [
      [
        {"digits": 1, "count": 3},
      ],
      [
        {"digits": 1, "count": 4},
      ],
      [
        {"digits": 1, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak8Mitori,
    problemCountPerTemplate: [15, 15, 20],
    repeat: 1,
  ),
  nsak7(
    templates: [
      [
        {"digits": 1, "count": 3},
      ],
      [
        {"digits": 1, "count": 4},
      ],
      [
        {"digits": 1, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak7Mitori,
    problemCountPerTemplate: [15, 15, 20],
    repeat: 1,
  ),
  nsak6(
    templates: [
      [
        {"digits": 1, "count": 4},
        {"digits": 2, "count": 1},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsak5(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 3},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsak4(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsakj3(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
      [
        {"digits": 3, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [10, 10],
    repeat: 1,
  ),
  nsak3(
    templates: [
      [
        {"digits": 3, "count": 5},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsakj2(
    templates: [
      [
        {"digits": 3, "count": 5},
      ],
      [
        {"digits": 3, "count": 7},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [10, 10],
    repeat: 1,
  ),
  nsak2(
    templates: [
      [
        {"digits": 3, "count": 7},
      ],
    ],
    minusCount: 0,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsakj1(
    templates: [
      [
        {"digits": 3, "count": 7},
      ],
      [
        {"digits": 3, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [10, 10],
    repeat: 1,
  ),
  nsak1(
    templates: [
      [
        {"digits": 3, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsak6To1Mitori,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsadan(
    templates: [
      [
        {"digits": 4, "count": 10},
      ],
      [
        {"digits": 6, "count": 10},
      ],
      [
        {"digits": 8, "count": 10},
      ],
    ],
    minusCount: 4,
    levelInfo: .nsadanMitori,
    problemCountPerTemplate: [10, 10, 10],
    repeat: 1,
  );

  const ComplexMitoriLevel({
    required this.templates,
    required this.minusCount,
    this.minusProblemsPerTemplate,
    this.minusCountPerGroup,
    required this.levelInfo,
    required this.problemCountPerTemplate,
    required this.repeat,
    this.neverNegative,
  });
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final List<int>? minusCountPerGroup;
  final int? minusProblemsPerTemplate;
  @override
  final LevelInfo levelInfo;
  final List<int> problemCountPerTemplate;
  final int repeat;
  final bool? neverNegative; // nisshou is always neverNegative

  @override
  Set<int> get letterCounts => templates
      .map(
        (group) =>
            group.fold(0, (sum, map) => sum + (map['digits']! * map['count']!)),
      )
      .toSet();
  @override
  int get problemCount =>
      problemCountPerTemplate.reduce((a, b) => a + b) * repeat;
  @override
  Set<int>? get houshouJippou => null;
  @override
  int get maxDigits =>
      templates
          .expand((group) => group)
          .map((map) => map['digits']!)
          .reduce((a, b) => a > b ? a : b) +
      ((minusCount > 0) ? 1 : 0);
}

enum Denomination { nisshou, zenshuren, kyoukai }

enum RankLabel {
  preShodan,
  shodan,
  preNidan,
  nidan,
  preSandan,
  sandan,
  preYondan,
  yondan,
  preGodan,
  godan,
  preRokudan,
  rokudan,
  nanadan,
  hachidan,
  kudan,
  judan,
}

const List<(RankLabel, int)> nsdanRangedThreshold = [
  (RankLabel.preShodan, 90),
  (RankLabel.shodan, 100),
  (RankLabel.preNidan, 110),
  (RankLabel.nidan, 120),
  (RankLabel.preSandan, 130),
  (RankLabel.sandan, 140),
  (RankLabel.yondan, 160),
  (RankLabel.godan, 180),
  (RankLabel.rokudan, 200),
  (RankLabel.nanadan, 220),
  (RankLabel.hachidan, 240),
  (RankLabel.kudan, 260),
  (RankLabel.judan, 280),
];
const List<(RankLabel, int)> zsdanRangedThreshold = [
  (RankLabel.preShodan, 80),
  (RankLabel.shodan, 100),
  (RankLabel.preNidan, 110),
  (RankLabel.nidan, 120),
  (RankLabel.preSandan, 130),
  (RankLabel.sandan, 140),
  (RankLabel.preYondan, 150),
  (RankLabel.yondan, 160),
  (RankLabel.preGodan, 170),
  (RankLabel.godan, 180),
  (RankLabel.preRokudan, 190),
  (RankLabel.rokudan, 200),
  (RankLabel.nanadan, 220),
  (RankLabel.hachidan, 240),
  (RankLabel.kudan, 260),
  (RankLabel.judan, 280),
];
const List<(RankLabel, int)> zsadanRangedThreshold = [
  (RankLabel.preShodan, 70),
  (RankLabel.shodan, 80),
  (RankLabel.preNidan, 85),
  (RankLabel.nidan, 90),
  (RankLabel.preSandan, 95),
  (RankLabel.sandan, 100),
  (RankLabel.preYondan, 105),
  (RankLabel.yondan, 110),
  (RankLabel.preGodan, 115),
  (RankLabel.godan, 120),
  (RankLabel.preRokudan, 125),
  (RankLabel.rokudan, 130),
  (RankLabel.nanadan, 140),
  (RankLabel.hachidan, 150),
  (RankLabel.kudan, 170),
  (RankLabel.judan, 190),
];

enum LevelInfo {
  nsk10Mult(
    passThreshold: 0.3,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk9Mult(
    passThreshold: 0.6,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk8To7DivMult(
    passThreshold: 0.6,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 5),
  ),
  nsk6To4DivMult(
    passThreshold: 0.7,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk3To1DivMult(
    passThreshold: 0.8,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk10Mitori(
    passThreshold: 0.3,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk9To7Mitori(
    passThreshold: 0.6,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk6To4Mitori(
    passThreshold: 0.7,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsk3To1Mitori(
    passThreshold: 0.8,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
  ),
  nsdanMitori(
    passThreshold: 0.33,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
    rangedThreshold: nsdanRangedThreshold,
  ),
  nsdanDivMult(
    passThreshold: 0.33,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 10),
    rangedThreshold: nsdanRangedThreshold,
  ),
  nsak10Mitori(
    passThreshold: 0.5,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 12),
  ),
  nsak9Mitori(
    passThreshold: 0.6,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 12),
  ),
  nsak8Mitori(
    passThreshold: 0.7,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 12),
  ),
  nsak7Mitori(
    passThreshold: 0.8,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 12),
  ),
  nsak6To1DivMult(
    passThreshold: 0.8,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 4),
  ),
  nsak6To1Mitori(
    passThreshold: 0.8,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 4),
  ),
  nsadanDivMult(
    passThreshold: 0.33,
    pointsPerProblem: 5,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 3),
    rangedThreshold: nsdanRangedThreshold,
  ),
  nsadanMitori(
    passThreshold: 0.33,
    pointsPerProblem: 10,
    denomination: .nisshou,
    timeLimit: Duration(minutes: 4),
    rangedThreshold: nsdanRangedThreshold,
  ),
  zs(
    passThreshold: 0.66,
    pointsPerProblem: 10,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 7),
  ),
  zsa(
    passThreshold: 0.7,
    pointsPerProblem: 5,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 3),
  ),
  zsak10to8(
    passThreshold: 0.7,
    pointsPerProblem: 10,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 3),
  ),
  zsdan(
    passThreshold: 0.33,
    pointsPerProblem: 10,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 7),
    rangedThreshold: zsdanRangedThreshold,
  ),
  zsadan(
    passThreshold: 0.4,
    pointsPerProblem: 5,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 7),
    rangedThreshold: zsadanRangedThreshold,
  ),
  zsflash(
    passThreshold: 0.66,
    pointsPerProblem: 10,
    denomination: .zenshuren,
    timeLimit: Duration(minutes: 7),
  ),
  kkflash(
    passThreshold: 0.7,
    pointsPerProblem: 10,
    denomination: .kyoukai,
    timeLimit: Duration(minutes: 7),
  );

  const LevelInfo({
    required this.denomination,
    required this.passThreshold,
    required this.pointsPerProblem,
    required this.timeLimit,
    this.rangedThreshold,
  });
  final Denomination denomination;
  final double passThreshold;
  final int pointsPerProblem;
  final Duration timeLimit;
  final List<(RankLabel, int)>? rangedThreshold;
}

sealed class Level {
  LevelInfo get levelInfo;
  int get maxDigits;
}

sealed class PaperProblemLevel implements Level {
  Set<int>? get letterCounts => null;
  int get problemCount => 10;
  Set<int>? get houshouJippou => null;
}

sealed class MitoriLevel implements PaperProblemLevel {}

enum Kyuui {
  nsk10(
    mitoriSoroban: .nsk10,
    mitoriAnzan: ComplexMitoriLevel.nsak10,
    multSoroban: .nsmk10,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk9(
    mitoriSoroban: .nsk9,
    mitoriAnzan: ComplexMitoriLevel.nsak9,
    multSoroban: .nsmk9,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk8(
    mitoriSoroban: .nsk8,
    mitoriAnzan: ComplexMitoriLevel.nsak8,
    multSoroban: .nsmk8,
    multAnzan: null,
    divSoroban: .nsdk8,
    divAnzan: null,
  ),
  nsk7(
    mitoriSoroban: .nsk7,
    mitoriAnzan: ComplexMitoriLevel.nsak7,
    multSoroban: .nsmk7,
    multAnzan: null,
    divSoroban: .nsdk7,
    divAnzan: null,
  ),
  nsk6(
    mitoriSoroban: .nsk6,
    mitoriAnzan: ComplexMitoriLevel.nsak6,
    multSoroban: .nsmk6,
    multAnzan: .nsmak4, //sic
    divSoroban: .nsdk6,
    divAnzan: .nsdak6,
  ),
  nsk5(
    mitoriSoroban: .nsk5,
    mitoriAnzan: ComplexMitoriLevel.nsak5,
    multSoroban: .nsmk5,
    multAnzan: .nsmak4, //sic
    divSoroban: .nsdk5,
    divAnzan: .nsdak5,
  ),
  nsk4(
    mitoriSoroban: .nsk4,
    mitoriAnzan: ComplexMitoriLevel.nsak4,
    multSoroban: .nsmk4,
    multAnzan: .nsmak4,
    divSoroban: .nsdk4,
    divAnzan: .nsdak4,
  ),
  nskj3(
    mitoriSoroban: .nskj3,
    mitoriAnzan: ComplexMitoriLevel.nsakj3,
    multSoroban: .nsmkj3,
    multAnzan: .nsmakj3,
    divSoroban: .nsdkj3,
    divAnzan: .nsdakj3,
  ),
  nsk3(
    mitoriSoroban: .nsk3,
    mitoriAnzan: ComplexMitoriLevel.nsak3,
    multSoroban: .nsmk3,
    multAnzan: .nsmak3,
    divSoroban: .nsdk3,
    divAnzan: .nsdak3,
  ),
  nskj2(
    mitoriSoroban: .nskj2,
    mitoriAnzan: ComplexMitoriLevel.nsakj2,
    multSoroban: .nsmkj2,
    multAnzan: .nsmakj2,
    divSoroban: .nsdkj2,
    divAnzan: .nsdakj2,
  ),
  nsk2(
    mitoriSoroban: .nsk2,
    mitoriAnzan: ComplexMitoriLevel.nsak2,
    multSoroban: .nsmk2,
    multAnzan: .nsmak2,
    divSoroban: .nsdk2,
    divAnzan: .nsdak2,
  ),
  nskj1(
    mitoriSoroban: .nskj1,
    mitoriAnzan: ComplexMitoriLevel.nsakj1,
    multSoroban: .nsmkj1,
    multAnzan: .nsmakj1,
    divSoroban: .nsdkj1,
    divAnzan: .nsdakj1,
  ),
  nsk1(
    mitoriSoroban: .nsk1,
    mitoriAnzan: ComplexMitoriLevel.nsak1,
    multSoroban: .nsmk1,
    multAnzan: .nsmak1,
    divSoroban: .nsdk1,
    divAnzan: .nsdak1,
  ),
  nsdan(
    mitoriSoroban: .nsdan,
    mitoriAnzan: ComplexMitoriLevel.nsadan,
    multSoroban: .nsmdan,
    multAnzan: .nsmadan,
    divSoroban: .nsddan,
    divAnzan: .nsdadan,
  ),
  zsk20(flash: .zsk20),
  zsk19(flash: .zsk19),
  zsk18(flash: .zsk18),
  zsk17(flash: .zsk17),
  zsk16(flash: .zsk16),
  zsk15(flash: .zsk15),
  zsk14(flash: .zsk14),
  zsk13(flash: .zsk13),
  zsk12(flash: .zsk12),
  zsk11(flash: .zsk11),
  zsk10(
    mitoriSoroban: .zsk10a, //TODO
    mitoriAnzan: SimpleMitoriLevel.zsak10,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    flash: .zsk10,
  ),
  zsk9(
    mitoriSoroban: .zsk9,
    mitoriAnzan: SimpleMitoriLevel.zsak9,
    multSoroban: .zsmk9,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    flash: .zsk9,
  ),
  zsk8(
    mitoriSoroban: .zsk8,
    mitoriAnzan: SimpleMitoriLevel.zsak8,
    multSoroban: .zsmk8,
    multAnzan: null,
    divSoroban: .zsdk8,
    divAnzan: null,
    flash: .zsk8,
  ),
  zsk7(
    mitoriSoroban: .zsk7,
    mitoriAnzan: ComplexMitoriLevel.zsak7,
    multSoroban: .zsmk7,
    multAnzan: .zsmak5, //sic
    divSoroban: .zsdk7,
    divAnzan: null,
    flash: .zsk7,
  ),
  zsk6(
    mitoriSoroban: .zsk6,
    mitoriAnzan: ComplexMitoriLevel.zsak6,
    multSoroban: .zsmk6,
    multAnzan: .zsmak5, //sic
    divSoroban: .zsdk6,
    divAnzan: .zsdak5, //sic
    flash: .zsk6,
  ),
  zsk5(
    mitoriSoroban: .zsk5,
    mitoriAnzan: ComplexMitoriLevel.zsak5,
    multSoroban: .zsmk5,
    multAnzan: .zsmak5,
    divSoroban: .zsdk5,
    divAnzan: .zsdak5,
    flash: .zsk5,
  ),
  zsk4(
    mitoriSoroban: .zsk4,
    mitoriAnzan: ComplexMitoriLevel.zsak4,
    multSoroban: .zsmk4,
    multAnzan: .zsmak4,
    divSoroban: .zsdk4,
    divAnzan: .zsdak4,
    flash: .zsk4,
  ),
  zsk3(
    mitoriSoroban: .zsk3,
    mitoriAnzan: ComplexMitoriLevel.zsak3,
    multSoroban: .zsmk3,
    multAnzan: .zsmak3,
    divSoroban: .zsdk3,
    divAnzan: .zsdak3,
    flash: .zsk3,
  ),
  zsk2(
    mitoriSoroban: .zsk2,
    mitoriAnzan: ComplexMitoriLevel.zsak2,
    multSoroban: .zsmk2,
    multAnzan: .zsmak2,
    divSoroban: .zsdk2,
    divAnzan: .zsdak2,
    flash: .zsk2,
  ),
  zsk1(
    mitoriSoroban: .zsk1,
    mitoriAnzan: ComplexMitoriLevel.zsak1,
    multSoroban: .zsmk1,
    multAnzan: .zsmak1,
    divSoroban: .zsdk1,
    divAnzan: .zsdak1,
    flash: .zsk1,
  ),
  zsdan(
    mitoriSoroban: .zsdan,
    mitoriAnzan: ComplexMitoriLevel.zsadan,
    multSoroban: .zsmdan,
    multAnzan: .zsmadan,
    divSoroban: .zsddan,
    divAnzan: .zsdadan,
  ),
  zsd1(flash: .zsd1),
  zsd2(flash: .zsd2),
  zsd3(flash: .zsd3),
  zsd4(flash: .zsd4),
  zsd5(flash: .zsd5),
  zsd6(flash: .zsd6),
  zsd7(flash: .zsd7),
  zsd8(flash: .zsd8),
  zsd9(flash: .zsd9),
  zsd10(flash: .zsd10),
  kkk20(flash: .kkk20),
  kkk19(flash: .kkk19),
  kkk18(flash: .kkk18),
  kkk17(flash: .kkk17),
  kkk16(flash: .kkk16),
  kkk15(flash: .kkk15),
  kkk14(flash: .kkk14),
  kkk13(flash: .kkk13),
  kkk12(flash: .kkk12),
  kkk11(flash: .kkk11),
  kkk10(flash: .kkk10),
  kkk9(flash: .kkk9),
  kkk8(flash: .kkk8),
  kkk7(flash: .kkk7),
  kkk6(flash: .kkk6),
  kkk5(flash: .kkk5),
  kkk4(flash: .kkk4),
  kkk3(flash: .kkk3),
  kkk2(flash: .kkk2),
  kkk1(flash: .kkk1),
  kkd1(flash: .kkd1),
  kkd2(flash: .kkd2),
  kkd3(flash: .kkd3),
  kkd4(flash: .kkd4),
  kkd5(flash: .kkd5),
  kkd6(flash: .kkd6),
  kkd7(flash: .kkd7),
  kkd8(flash: .kkd8),
  kkd9(flash: .kkd9),
  kkd10(flash: .kkd10);

  const Kyuui({
    this.mitoriSoroban,
    this.mitoriAnzan,
    this.multSoroban,
    this.multAnzan,
    this.divSoroban,
    this.divAnzan,
    this.flash,
  });
  final ComplexMitoriLevel? mitoriSoroban;
  final MitoriLevel? mitoriAnzan;
  final DivMultLevel? multSoroban;
  final DivMultLevel? multAnzan;
  final DivMultLevel? divSoroban;
  final DivMultLevel? divAnzan;
  final FlashLevel? flash;
}

enum SimpleMitoriLevel implements MitoriLevel {
  zsak10(levelInfo: .zsak10to8),
  zsak9(levelInfo: .zsak10to8),
  zsak8(levelInfo: .zsak10to8);

  const SimpleMitoriLevel({required this.levelInfo});
  @override
  final LevelInfo levelInfo;

  @override
  Set<int>? get letterCounts => switch (this) {
    zsak10 => {3, 4},
    zsak9 || zsak8 => {4},
  };
  @override
  int get problemCount => 10;
  @override
  Set<int>? get houshouJippou => null;
  @override
  int get maxDigits => 2;
}

enum KyuuiDenomination {
  zs(
    k10: .zsk10,
    k9: .zsk9,
    k8: .zsk8,
    k7: .zsk7,
    k6: .zsk6,
    k5: .zsk5,
    k4: .zsk4,
    k3: .zsk3,
    k2: .zsk2,
    k1: .zsk1,
    dan: .zsdan,
  ),
  zsFlash(
    k20: .zsk20,
    k19: .zsk19,
    k18: .zsk18,
    k17: .zsk17,
    k16: .zsk16,
    k15: .zsk15,
    k14: .zsk14,
    k13: .zsk13,
    k12: .zsk12,
    k11: .zsk11,
    k10: .zsk10,
    k9: .zsk9,
    k8: .zsk8,
    k7: .zsk7,
    k6: .zsk6,
    k5: .zsk5,
    k4: .zsk4,
    k3: .zsk3,
    k2: .zsk2,
    k1: .zsk1,
    d1: .zsd1,
    d2: .zsd2,
    d3: .zsd3,
    d4: .zsd4,
    d5: .zsd5,
    d6: .zsd6,
    d7: .zsd7,
    d8: .zsd8,
    d9: .zsd9,
    d10: .zsd10,
  ),
  kkFlash(
    k20: .kkk20,
    k19: .kkk19,
    k18: .kkk18,
    k17: .kkk17,
    k16: .kkk16,
    k15: .kkk15,
    k14: .kkk14,
    k13: .kkk13,
    k12: .kkk12,
    k11: .kkk11,
    k10: .kkk10,
    k9: .kkk9,
    k8: .kkk8,
    k7: .kkk7,
    k6: .kkk6,
    k5: .kkk5,
    k4: .kkk4,
    k3: .kkk3,
    k2: .kkk2,
    k1: .kkk1,
    d1: .kkd1,
    d2: .kkd2,
    d3: .kkd3,
    d4: .kkd4,
    d5: .kkd5,
    d6: .kkd6,
    d7: .kkd7,
    d8: .kkd8,
    d9: .kkd9,
    d10: .kkd10,
  ),
  ns(
    k10: .nsk10,
    k9: .nsk9,
    k8: .nsk8,
    k7: .nsk7,
    k6: .nsk6,
    k5: .nsk5,
    k4: .nsk4,
    kj3: .nskj3,
    k3: .nsk3,
    kj2: .nskj2,
    k2: .nsk2,
    kj1: .nskj1,
    k1: .nsk1,
    dan: .nsdan,
  );

  const KyuuiDenomination({
    this.k11,
    this.k12,
    this.k13,
    this.k14,
    this.k15,
    this.k16,
    this.k17,
    this.k18,
    this.k19,
    this.k20,
    this.d10,
    this.d9,
    this.d8,
    this.d7,
    this.d6,
    this.d5,
    this.d4,
    this.d3,
    this.d2,
    this.d1,
    this.dan,
    required this.k1,
    this.kj1,
    required this.k2,
    this.kj2,
    required this.k3,
    this.kj3,
    required this.k4,
    required this.k5,
    required this.k6,
    required this.k7,
    required this.k8,
    required this.k9,
    required this.k10,
  });

  final Kyuui? d10;
  final Kyuui? d9;
  final Kyuui? d8;
  final Kyuui? d7;
  final Kyuui? d6;
  final Kyuui? d5;
  final Kyuui? d4;
  final Kyuui? d3;
  final Kyuui? d2;
  final Kyuui? d1;
  final Kyuui? dan;
  final Kyuui k1;
  final Kyuui? kj1;
  final Kyuui k2;
  final Kyuui? kj2;
  final Kyuui k3;
  final Kyuui? kj3;
  final Kyuui k4;
  final Kyuui k5;
  final Kyuui k6;
  final Kyuui k7;
  final Kyuui k8;
  final Kyuui k9;
  final Kyuui k10;
  final Kyuui? k11;
  final Kyuui? k12;
  final Kyuui? k13;
  final Kyuui? k14;
  final Kyuui? k15;
  final Kyuui? k16;
  final Kyuui? k17;
  final Kyuui? k18;
  final Kyuui? k19;
  final Kyuui? k20;
}
