import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel implements PaperProblemLevel {
  zsmk9(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.zsk9,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk8(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.zsk8,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk7(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.zsk7,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk6(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.zsk6,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmak5(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.zsak5,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk5(
    split: .sixDigit,
    divMultSource: MultiplicationSource.zsk5,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmak4(
    split: .threeAndFourB,
    divMultSource: MultiplicationSource.zsak4,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk4(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.zsk4,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmak3(
    split: .fourSpecialB,
    divMultSource: MultiplicationSource.zsak3,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk3(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.zsk3,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmak2(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.zsak2,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk2(
    split: .eightDigit,
    divMultSource: MultiplicationSource.zsk2,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmak1(
    split: .fourAndFive,
    divMultSource: MultiplicationSource.zsak1,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk1(
    split: .nineDigit,
    divMultSource: MultiplicationSource.zsk1,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmdan(
    split: .zsmdan,
    divMultSource: MultiplicationSource.zsdan,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmadan(
    split: .fourToEight,
    divMultSource: MultiplicationSource.zsadan,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsdk8(
    split: .threeDigitB,
    divMultSource: DivisionSource.zsk8,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk7(
    split: .fourDigitC,
    divMultSource: DivisionSource.zsk7,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk6(
    split: .fourDigitB,
    divMultSource: DivisionSource.zsk6,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdak5(
    split: .threeDigitB,
    divMultSource: DivisionSource.zsak5,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk5(
    split: .fiveDigit,
    divMultSource: DivisionSource.zsk5,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdak4(
    split: .threeAndFourA,
    divMultSource: DivisionSource.zsak4,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk4(
    split: .sixDigit,
    divMultSource: DivisionSource.zsk4,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdak3(
    split: .fourSpecialA,
    divMultSource: DivisionSource.zsak3,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk3(
    split: .sixDigit,
    divMultSource: DivisionSource.zsk3,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdak2(
    split: .fourDigitB,
    divMultSource: DivisionSource.zsak2,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk2(
    split: .sevenDigit,
    divMultSource: DivisionSource.zsk2,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdak1(
    split: .fourAndFive,
    divMultSource: DivisionSource.zsak1,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk1(
    split: .eightDigit,
    divMultSource: DivisionSource.zsk1,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdadan(
    split: .fourToEight,
    divMultSource: DivisionSource.zsadan,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsddan(
    split: .zsddan,
    divMultSource: DivisionSource.zsdan,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  nsmk9(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.nsk9,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk8(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.nsk8,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk7(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.nsk7,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk6(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.nsk6,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk5(
    split: .sixDigit,
    divMultSource: MultiplicationSource.nsk5,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk4(
    split: .sevenDigit,
    divMultSource: MultiplicationSource.nsk4,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmkj3(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nskj3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk3(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nsk3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmkj2(
    split: .eightDigit,
    divMultSource: MultiplicationSource.nskj2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk2(
    split: .nineDigit,
    divMultSource: MultiplicationSource.nsk2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmkj1(
    split: .tenDigit,
    divMultSource: MultiplicationSource.nskj1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk1(
    split: .elevenDigit,
    divMultSource: MultiplicationSource.nsk1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmdan(
    split: .elevenDigit,
    divMultSource: MultiplicationSource.nsdan,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsdk8(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsk8,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk7(
    split: .fourDigitC,
    divMultSource: DivisionSource.nsk7,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk6(
    split: .fourDigitB,
    divMultSource: DivisionSource.nsk6,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk5(
    split: .fiveDigit,
    divMultSource: DivisionSource.nsk5,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk4(
    split: .sixDigit,
    divMultSource: DivisionSource.nsk4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdkj3(
    split: .sixDigit,
    divMultSource: DivisionSource.nsjk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk3(
    split: .sixDigit,
    divMultSource: DivisionSource.nsk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdkj2(
    split: .sevenDigit,
    divMultSource: DivisionSource.nsjk2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk2(
    split: .eightDigit,
    divMultSource: DivisionSource.nsk2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdkj1(
    split: .nineDigit,
    divMultSource: DivisionSource.nsjk1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk1(
    split: .tenDigit,
    divMultSource: DivisionSource.nsk1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsddan(
    split: .tenDigit,
    divMultSource: DivisionSource.nsdan,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak6(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak5(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak4(
    split: .threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj3(
    split: .threeAndFourA,
    divMultSource: DivisionSource.nsajk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak3(
    split: .fourDigitC,
    divMultSource: DivisionSource.nsak3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj2(
    split: .fourSpecialA,
    divMultSource: DivisionSource.nsakj2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak2(
    split: .fourDigitB,
    divMultSource: DivisionSource.nsak2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj1(
    split: .fourAndFive,
    divMultSource: DivisionSource.nsakj1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak1(
    split: .fiveDigit,
    divMultSource: DivisionSource.nsak1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdadan(
    split: .nsadan,
    divMultSource: DivisionSource.nsadan,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsmak4(
    split: .threeDigitA,
    divMultSource: MultiplicationSource.nsak4, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj3(
    split: .threeAndFourB,
    divMultSource: MultiplicationSource.nsakj3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak3(
    split: .fourDigitA,
    divMultSource: MultiplicationSource.nsak2, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj2(
    split: .fourSpecialB,
    divMultSource: MultiplicationSource.nsakj2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak2(
    split: .fourDigitB,
    divMultSource: MultiplicationSource.nsak2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj1(
    split: .fourAndFive,
    divMultSource: MultiplicationSource.nsakj1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak1(
    split: .fiveDigit,
    divMultSource: MultiplicationSource.nsak1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmadan(
    split: .nsadan,
    divMultSource: MultiplicationSource.nsdan,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  );

  const DivMultLevel({
    required this.split,
    required this.divMultSource,
    required this.denomination,
    required this.builder,
  });
  final Split split;
  final DivMultSource divMultSource;
  @override
  final PaperDenomination denomination;
  final Function builder;
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
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
    denomination: .zenshuren,
    problemCountPerTemplate: [4, 4, 7, 5, 5, 5, 5, 5],
    repeat: 1,
    neverNegative: true,
  ),
  nsk9(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 1,
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
    problemCountPerTemplate: [30],
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
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
    denomination: .nisshou,
    problemCountPerTemplate: [20],
    repeat: 1,
  ),
  nsadan(
    templates: [
      [
        {"digits": 3, "count": 10},
      ],
    ],
    minusCount: 4,
    denomination: .nisshou,
    problemCountPerTemplate: [20],
    repeat: 1,
  );

  const ComplexMitoriLevel({
    required this.templates,
    required this.minusCount,
    this.minusProblemsPerTemplate,
    this.minusCountPerGroup,
    required this.denomination,
    required this.problemCountPerTemplate,
    required this.repeat,
    this.neverNegative,
  });
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final List<int>? minusCountPerGroup;
  final int? minusProblemsPerTemplate;
  @override
  final PaperDenomination denomination;
  final List<int> problemCountPerTemplate;
  final int repeat;
  final bool? neverNegative; // nisshou is always neverNegative
}

enum PaperDenomination {
  nisshou(passThreshold: 0.66, timeLimit: Duration(minutes: 10)),
  zenshuren(passThreshold: 0.7, timeLimit: Duration(minutes: 7));

  const PaperDenomination({
    required this.passThreshold,
    required this.timeLimit,
  });
  final double passThreshold;
  final Duration timeLimit;
}

sealed class PaperProblemLevel {
  PaperDenomination get denomination;
}

sealed class MitoriLevel implements PaperProblemLevel {}

enum Kyuui {
  nsk10(
    mitoriSoroban: .nsk9,
    mitoriAnzan: ComplexMitoriLevel.nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    kyuuString: '10級',
  ),
  nsk9(
    mitoriSoroban: .nsk9,
    mitoriAnzan: ComplexMitoriLevel.nsak7,
    multSoroban: .nsmk9,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    kyuuString: '9級',
  ),
  nsk8(
    mitoriSoroban: .nsk8,
    mitoriAnzan: ComplexMitoriLevel.nsak7,
    multSoroban: .nsmk8,
    multAnzan: null,
    divSoroban: .nsdk8,
    divAnzan: null,
    kyuuString: '8級',
  ),
  nsk7(
    mitoriSoroban: .nsk7,
    mitoriAnzan: ComplexMitoriLevel.nsak7,
    multSoroban: .nsmk7,
    multAnzan: null,
    divSoroban: .nsdk7,
    divAnzan: null,
    kyuuString: '7級',
  ),
  nsk6(
    mitoriSoroban: .nsk6,
    mitoriAnzan: ComplexMitoriLevel.nsak6,
    multSoroban: .nsmk6,
    multAnzan: .nsmak4, //sic
    divSoroban: .nsdk6,
    divAnzan: .nsdak6,
    kyuuString: '6級',
  ),
  nsk5(
    mitoriSoroban: .nsk5,
    mitoriAnzan: ComplexMitoriLevel.nsak5,
    multSoroban: .nsmk5,
    multAnzan: .nsmak4, //sic
    divSoroban: .nsdk5,
    divAnzan: .nsdak5,
    kyuuString: '5級',
  ),
  nsk4(
    mitoriSoroban: .nsk4,
    mitoriAnzan: ComplexMitoriLevel.nsak4,
    multSoroban: .nsmk4,
    multAnzan: .nsmak4,
    divSoroban: .nsdk4,
    divAnzan: .nsdak4,
    kyuuString: '4級',
  ),
  nskj3(
    mitoriSoroban: .nskj3,
    mitoriAnzan: ComplexMitoriLevel.nsakj3,
    multSoroban: .nsmkj3,
    multAnzan: .nsmakj3,
    divSoroban: .nsdkj3,
    divAnzan: .nsdakj3,
    kyuuString: '準3級',
  ),
  nsk3(
    mitoriSoroban: .nsk3,
    mitoriAnzan: ComplexMitoriLevel.nsak3,
    multSoroban: .nsmk3,
    multAnzan: .nsmak3,
    divSoroban: .nsdk3,
    divAnzan: .nsdak3,
    kyuuString: '3級',
  ),
  nskj2(
    mitoriSoroban: .nskj2,
    mitoriAnzan: ComplexMitoriLevel.nsakj2,
    multSoroban: .nsmkj2,
    multAnzan: .nsmakj2,
    divSoroban: .nsdkj2,
    divAnzan: .nsdakj2,
    kyuuString: '準2級',
  ),
  nsk2(
    mitoriSoroban: .nsk2,
    mitoriAnzan: ComplexMitoriLevel.nsak2,
    multSoroban: .nsmk2,
    multAnzan: .nsmak2,
    divSoroban: .nsdk2,
    divAnzan: .nsdak2,
    kyuuString: '2級',
  ),
  nskj1(
    mitoriSoroban: .nskj1,
    mitoriAnzan: ComplexMitoriLevel.nsakj1,
    multSoroban: .nsmkj1,
    multAnzan: .nsmakj1,
    divSoroban: .nsdkj1,
    divAnzan: .nsdakj1,
    kyuuString: '準1級',
  ),
  nsk1(
    mitoriSoroban: .nsk1,
    mitoriAnzan: ComplexMitoriLevel.nsak1,
    multSoroban: .nsmk1,
    multAnzan: .nsmak1,
    divSoroban: .nsdk1,
    divAnzan: .nsdak1,
    kyuuString: '1級',
  ),
  nsdan(
    mitoriSoroban: .nsdan,
    mitoriAnzan: ComplexMitoriLevel.nsadan,
    multSoroban: .nsmdan,
    multAnzan: .nsmadan,
    divSoroban: .nsddan,
    divAnzan: .nsdadan,
    kyuuString: '段位',
  ),
  zsk10(
    mitoriSoroban: .zsk10a, //TODO
    mitoriAnzan: SimpleMitoriLevel.zsak10,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    kyuuString: '10級',
  ),
  zsk9(
    mitoriSoroban: .zsk9,
    mitoriAnzan: SimpleMitoriLevel.zsak9,
    multSoroban: .zsmk9,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
    kyuuString: '9級',
  ),
  zsk8(
    mitoriSoroban: .zsk8,
    mitoriAnzan: SimpleMitoriLevel.zsak8,
    multSoroban: .zsmk8,
    multAnzan: null,
    divSoroban: .zsdk8,
    divAnzan: null,
    kyuuString: '8級',
  ),
  zsk7(
    mitoriSoroban: .zsk7,
    mitoriAnzan: ComplexMitoriLevel.zsak7,
    multSoroban: .zsmk7,
    multAnzan: .zsmak5, //sic
    divSoroban: .zsdk7,
    divAnzan: null,
    kyuuString: '7級',
  ),
  zsk6(
    mitoriSoroban: .zsk6,
    mitoriAnzan: ComplexMitoriLevel.zsak6,
    multSoroban: .zsmk6,
    multAnzan: .zsmak5, //sic
    divSoroban: .zsdk6,
    divAnzan: .zsdak5, //sic
    kyuuString: '6級',
  ),
  zsk5(
    mitoriSoroban: .zsk5,
    mitoriAnzan: ComplexMitoriLevel.zsak5,
    multSoroban: .zsmk5,
    multAnzan: .zsmak5,
    divSoroban: .zsdk5,
    divAnzan: .zsdak5,
    kyuuString: '5級',
  ),
  zsk4(
    mitoriSoroban: .zsk4,
    mitoriAnzan: ComplexMitoriLevel.zsak4,
    multSoroban: .zsmk4,
    multAnzan: .zsmak4,
    divSoroban: .zsdk4,
    divAnzan: .zsdak4,
    kyuuString: '4級',
  ),
  zsk3(
    mitoriSoroban: .zsk3,
    mitoriAnzan: ComplexMitoriLevel.zsak3,
    multSoroban: .zsmk3,
    multAnzan: .zsmak3,
    divSoroban: .zsdk3,
    divAnzan: .zsdak3,
    kyuuString: '3級',
  ),
  zsk2(
    mitoriSoroban: .zsk2,
    mitoriAnzan: ComplexMitoriLevel.zsak2,
    multSoroban: .zsmk2,
    multAnzan: .zsmak2,
    divSoroban: .zsdk2,
    divAnzan: .zsdak2,
    kyuuString: '2級',
  ),
  zsk1(
    mitoriSoroban: .zsk1,
    mitoriAnzan: ComplexMitoriLevel.zsak1,
    multSoroban: .zsmk1,
    multAnzan: .zsmak1,
    divSoroban: .zsdk1,
    divAnzan: .zsdak1,
    kyuuString: '1級',
  ),
  zsdan(
    mitoriSoroban: .zsdan,
    mitoriAnzan: ComplexMitoriLevel.zsadan,
    multSoroban: .zsmdan,
    multAnzan: .zsmadan,
    divSoroban: .zsddan,
    divAnzan: .zsdadan,
    kyuuString: '段位',
  );

  const Kyuui({
    required this.mitoriSoroban,
    required this.mitoriAnzan,
    required this.multSoroban,
    required this.multAnzan,
    required this.divSoroban,
    required this.divAnzan,
    required this.kyuuString,
  });
  final ComplexMitoriLevel mitoriSoroban;
  final MitoriLevel mitoriAnzan;
  final DivMultLevel? multSoroban;
  final DivMultLevel? multAnzan;
  final DivMultLevel? divSoroban;
  final DivMultLevel? divAnzan;
  final String kyuuString;
}

enum SimpleMitoriLevel implements MitoriLevel {
  zsak10(denomination: .zenshuren),
  zsak9(denomination: .zenshuren),
  zsak8(denomination: .zenshuren);

  const SimpleMitoriLevel({required this.denomination});
  @override
  final PaperDenomination denomination;
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
    required this.dan,
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

  final Kyuui dan;
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
}
