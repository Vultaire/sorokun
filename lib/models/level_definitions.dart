import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel implements PaperProblemLevel {
  zsmk9(
    split: Split.threeDigitA,
    divMultSource: MultiplicationSource.zsk9,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk8(
    split: Split.fourDigitA,
    divMultSource: MultiplicationSource.zsk8,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk7(
    split: Split.fourDigitB,
    divMultSource: MultiplicationSource.zsk7,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk6(
    split: Split.fiveDigit,
    divMultSource: MultiplicationSource.zsk6,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk5(
    split: Split.sixDigit,
    divMultSource: MultiplicationSource.zsk5,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk4(
    split: Split.sevenDigit,
    divMultSource: MultiplicationSource.zsk4,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk3(
    split: Split.sevenDigit,
    divMultSource: MultiplicationSource.zsk3,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk2(
    split: Split.eightDigit,
    divMultSource: MultiplicationSource.zsk2,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmk1(
    split: Split.nineDigit,
    divMultSource: MultiplicationSource.zsk1,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsmdan(
    split: Split.zsmdan,
    divMultSource: MultiplicationSource.zsdan,
    denomination: .zenshuren,
    builder: MultiplicationProblem.new,
  ),
  zsdk8(
    split: Split.threeDigitB,
    divMultSource: DivisionSource.zsk8,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk7(
    split: Split.fourDigitC,
    divMultSource: DivisionSource.zsk7,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk6(
    split: Split.fourDigitB,
    divMultSource: DivisionSource.zsk6,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk5(
    split: Split.fiveDigit,
    divMultSource: DivisionSource.zsk5,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk4(
    split: Split.sixDigit,
    divMultSource: DivisionSource.zsk4,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk3(
    split: Split.sixDigit,
    divMultSource: DivisionSource.zsk3,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk2(
    split: Split.sevenDigit,
    divMultSource: DivisionSource.zsk2,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsdk1(
    split: Split.eightDigit,
    divMultSource: DivisionSource.zsk1,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  zsddan(
    split: Split.zsddan,
    divMultSource: DivisionSource.dzsan,
    denomination: .zenshuren,
    builder: DivisionProblem.new,
  ),
  nsmk9(
    split: Split.threeDigitA,
    divMultSource: MultiplicationSource.nsk9,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk8(
    split: Split.fourDigitA,
    divMultSource: MultiplicationSource.nsk8,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk7(
    split: Split.fourDigitB,
    divMultSource: MultiplicationSource.nsk7,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk6(
    split: Split.fiveDigit,
    divMultSource: MultiplicationSource.nsk6,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk5(
    split: Split.sixDigit,
    divMultSource: MultiplicationSource.nsk5,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk4(
    split: Split.sevenDigit,
    divMultSource: MultiplicationSource.nsk4,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmjk3(
    split: Split.eightDigit,
    divMultSource: MultiplicationSource.nskj3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk3(
    split: Split.eightDigit,
    divMultSource: MultiplicationSource.nsk3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmjk2(
    split: Split.eightDigit,
    divMultSource: MultiplicationSource.nskj2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk2(
    split: Split.nineDigit,
    divMultSource: MultiplicationSource.nsk2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmjk1(
    split: Split.tenDigit,
    divMultSource: MultiplicationSource.nskj1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmk1(
    split: Split.elevenDigit,
    divMultSource: MultiplicationSource.nsk1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmdan(
    split: Split.elevenDigit,
    divMultSource: MultiplicationSource.nsdan,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsdk8(
    split: Split.threeDigitB,
    divMultSource: DivisionSource.nsk8,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk7(
    split: Split.fourDigitC,
    divMultSource: DivisionSource.nsk7,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk6(
    split: Split.fourDigitB,
    divMultSource: DivisionSource.nsk6,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk5(
    split: Split.fiveDigit,
    divMultSource: DivisionSource.nsk5,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk4(
    split: Split.sixDigit,
    divMultSource: DivisionSource.nsk4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdjk3(
    split: Split.sixDigit,
    divMultSource: DivisionSource.nsjk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk3(
    split: Split.sixDigit,
    divMultSource: DivisionSource.nsk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdjk2(
    split: Split.sevenDigit,
    divMultSource: DivisionSource.nsjk2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk2(
    split: Split.eightDigit,
    divMultSource: DivisionSource.nsk2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdjk1(
    split: Split.nineDigit,
    divMultSource: DivisionSource.nsjk1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdk1(
    split: Split.tenDigit,
    divMultSource: DivisionSource.nsk1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsddan(
    split: Split.tenDigit,
    divMultSource: DivisionSource.nsdan,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak6(
    split: Split.threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak5(
    split: Split.threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak4(
    split: Split.threeDigitB,
    divMultSource: DivisionSource.nsak4,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj3(
    split: Split.nsdakj3,
    divMultSource: DivisionSource.nsajk3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak3(
    split: Split.fourDigitC,
    divMultSource: DivisionSource.nsak3,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj2(
    split: Split.nsdakj2,
    divMultSource: DivisionSource.nsakj2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak2(
    split: Split.fourDigitB,
    divMultSource: DivisionSource.nsak2,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdakj1(
    split: Split.nsakj1,
    divMultSource: DivisionSource.nsakj1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdak1(
    split: Split.fiveDigit,
    divMultSource: DivisionSource.nsak1,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsdadan(
    split: Split.nsadan,
    divMultSource: DivisionSource.nsadan,
    denomination: .nisshou,
    builder: DivisionProblem.new,
  ),
  nsmak6(
    split: Split.threeDigitA,
    divMultSource: MultiplicationSource.nsak4, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak5(
    split: Split.threeDigitA,
    divMultSource: MultiplicationSource.nsak4, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak4(
    split: Split.threeDigitA,
    divMultSource: MultiplicationSource.nsak4, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj3(
    split: Split.nsmakj3,
    divMultSource: MultiplicationSource.nsakj3,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak3(
    split: Split.fourDigitA,
    divMultSource: MultiplicationSource.nsak2, // sic
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj2(
    split: Split.nsmakj2,
    divMultSource: MultiplicationSource.nsakj2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak2(
    split: Split.fourDigitB,
    divMultSource: MultiplicationSource.nsak2,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmakj1(
    split: Split.nsakj1,
    divMultSource: MultiplicationSource.nsakj1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmak1(
    split: Split.fiveDigit,
    divMultSource: MultiplicationSource.nsak1,
    denomination: .nisshou,
    builder: MultiplicationProblem.new,
  ),
  nsmadan(
    split: Split.tenDigit,
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

enum MitoriLevel implements PaperProblemLevel {
  zsk10a(
    templates: [
      [
        {"digits": 1, "count": 6},
      ],
    ],
    minusCount: 2,
    minusProblemsPerTemplate: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [5],
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
    templateCountPerGroup: [3, 2],
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
    templateCountPerGroup: [3, 2],
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
    templateCountPerGroup: [3, 2],
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
    templateCountPerGroup: [5, 5, 5, 5, 5, 5],
    repeat: 1,
    neverNegative: false,
  ),
  nsk9(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 1,
    denomination: .nisshou,
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [5, 5],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [10],
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
    templateCountPerGroup: [30],
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
    templateCountPerGroup: [15, 15, 20],
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
    templateCountPerGroup: [20],
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
    templateCountPerGroup: [20],
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
    templateCountPerGroup: [20],
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
    templateCountPerGroup: [10, 10],
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
    templateCountPerGroup: [20],
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
    templateCountPerGroup: [10, 10],
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
    templateCountPerGroup: [20],
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
    templateCountPerGroup: [10, 10],
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
    templateCountPerGroup: [20],
    repeat: 1,
  );

  const MitoriLevel({
    required this.templates,
    required this.minusCount,
    this.minusProblemsPerTemplate,
    required this.denomination,
    required this.templateCountPerGroup,
    required this.repeat,
    this.neverNegative,
  });
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final int? minusProblemsPerTemplate;
  @override
  final PaperDenomination denomination;
  final List<int> templateCountPerGroup;
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

enum Kyuui {
  nsk10(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk9(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: .nsmk9,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk8(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk7(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk6(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk5(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk4(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nskj3(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk3(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nskj2(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk2(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nskj1(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsk1(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  nsdan(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk10(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk9(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk8(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk7(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk6(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk5(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk4(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zskj3(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk3(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zskj2(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk2(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zskj1(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsk1(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  ),
  zsdan(
    mitoriSoroban: .nsk9,
    mitoriAnzan: .nsak7,
    multSoroban: null,
    multAnzan: null,
    divSoroban: null,
    divAnzan: null,
  );

  const Kyuui({
    required this.mitoriSoroban,
    required this.mitoriAnzan,
    required this.multSoroban,
    required this.multAnzan,
    required this.divSoroban,
    required this.divAnzan,
  });
  final MitoriLevel mitoriSoroban;
  final MitoriLevel mitoriAnzan;
  final DivMultLevel? multSoroban;
  final DivMultLevel? multAnzan;
  final DivMultLevel? divSoroban;
  final DivMultLevel? divAnzan;
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
    kj3: .zskj3,
    k3: .zsk3,
    kj2: .zskj2,
    k2: .zsk2,
    kj1: .zskj1,
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
    required this.kj1,
    required this.k2,
    required this.kj2,
    required this.k3,
    required this.kj3,
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
  final Kyuui kj1;
  final Kyuui k2;
  final Kyuui kj2;
  final Kyuui k3;
  final Kyuui kj3;
  final Kyuui k4;
  final Kyuui k5;
  final Kyuui k6;
  final Kyuui k7;
  final Kyuui k8;
  final Kyuui k9;
  final Kyuui k10;
}
