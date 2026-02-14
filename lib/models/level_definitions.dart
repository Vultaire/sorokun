import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel implements PaperProblemLevel {
  zsmk9(
    divMultSplit: MultiplicationSplit.k9,
    divMultSource: MultiplicationSource.k9,
    denomination: .zenshuren,
    displayString: '9級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk8(
    divMultSplit: MultiplicationSplit.k8,
    divMultSource: MultiplicationSource.k8,
    denomination: .zenshuren,
    displayString: '8級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk7(
    divMultSplit: MultiplicationSplit.k7,
    divMultSource: MultiplicationSource.k7,
    denomination: .zenshuren,
    displayString: '7級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk6(
    divMultSplit: MultiplicationSplit.k6,
    divMultSource: MultiplicationSource.k6,
    denomination: .zenshuren,
    displayString: '6級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk5(
    divMultSplit: MultiplicationSplit.k5,
    divMultSource: MultiplicationSource.k5,
    denomination: .zenshuren,
    displayString: '5級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk4(
    divMultSplit: MultiplicationSplit.k4,
    divMultSource: MultiplicationSource.k4,
    denomination: .zenshuren,
    displayString: '4級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk3(
    divMultSplit: MultiplicationSplit.k3,
    divMultSource: MultiplicationSource.k3,
    denomination: .zenshuren,
    displayString: '3級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk2(
    divMultSplit: MultiplicationSplit.k2,
    divMultSource: MultiplicationSource.k2,
    denomination: .zenshuren,
    displayString: '2級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmk1(
    divMultSplit: MultiplicationSplit.k1,
    divMultSource: MultiplicationSource.k1,
    denomination: .zenshuren,
    displayString: '1級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsmdan(
    divMultSplit: MultiplicationSplit.dan,
    divMultSource: MultiplicationSource.zsdan,
    denomination: .zenshuren,
    displayString: '段位のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk8(
    divMultSplit: DivisionSplit.k8,
    divMultSource: DivisionSource.k8,
    denomination: .zenshuren,
    displayString: '8級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk7(
    divMultSplit: DivisionSplit.k7,
    divMultSource: DivisionSource.k7,
    denomination: .zenshuren,
    displayString: '7級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk6(
    divMultSplit: DivisionSplit.k6,
    divMultSource: DivisionSource.k6,
    denomination: .zenshuren,
    displayString: '6級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk5(
    divMultSplit: DivisionSplit.k5,
    divMultSource: DivisionSource.k5,
    denomination: .zenshuren,
    displayString: '5級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk4(
    divMultSplit: DivisionSplit.k4,
    divMultSource: DivisionSource.k4,
    denomination: .zenshuren,
    displayString: '4級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk3(
    divMultSplit: DivisionSplit.k3,
    divMultSource: DivisionSource.k3,
    denomination: .zenshuren,
    displayString: '3級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk2(
    divMultSplit: DivisionSplit.k2,
    divMultSource: DivisionSource.k2,
    denomination: .zenshuren,
    displayString: '2級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsdk1(
    divMultSplit: DivisionSplit.k1,
    divMultSource: DivisionSource.k1,
    denomination: .zenshuren,
    displayString: '1級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  zsddan(
    divMultSplit: DivisionSplit.dan,
    divMultSource: DivisionSource.dan,
    denomination: .zenshuren,
    displayString: '段位のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 7),
  ),
  nsmk9(
    divMultSplit: MultiplicationSplit.k9,
    divMultSource: MultiplicationSource.nsk9,
    denomination: .nisshou,
    displayString: '10/9級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk8(
    divMultSplit: MultiplicationSplit.k8,
    divMultSource: MultiplicationSource.nsk8,
    denomination: .nisshou,
    displayString: '8級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk7(
    divMultSplit: MultiplicationSplit.k7,
    divMultSource: MultiplicationSource.nsk7,
    denomination: .nisshou,
    displayString: '7級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk6(
    divMultSplit: MultiplicationSplit.k6,
    divMultSource: MultiplicationSource.nsk6,
    denomination: .nisshou,
    displayString: '6級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk5(
    divMultSplit: MultiplicationSplit.k5,
    divMultSource: MultiplicationSource.nsk5,
    denomination: .nisshou,
    displayString: '5級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk4(
    divMultSplit: MultiplicationSplit.k4,
    divMultSource: MultiplicationSource.nsk4,
    denomination: .nisshou,
    displayString: '4級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmjk3(
    divMultSplit: MultiplicationSplit.k3,
    divMultSource: MultiplicationSource.nsjk3,
    denomination: .nisshou,
    displayString: '準3級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk3(
    divMultSplit: MultiplicationSplit.k3,
    divMultSource: MultiplicationSource.nsk3,
    denomination: .nisshou,
    displayString: '3級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmjk2(
    divMultSplit: MultiplicationSplit.k2,
    divMultSource: MultiplicationSource.nsjk2,
    denomination: .nisshou,
    displayString: '準2級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk2(
    divMultSplit: MultiplicationSplit.k1,
    divMultSource: MultiplicationSource.nsk2,
    denomination: .nisshou,
    displayString: '2級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmjk1(
    divMultSplit: MultiplicationSplit.nsjk1,
    divMultSource: MultiplicationSource.nsjk1,
    denomination: .nisshou,
    displayString: '準1級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmk1(
    divMultSplit: MultiplicationSplit.nsk1,
    divMultSource: MultiplicationSource.nsk1,
    denomination: .nisshou,
    displayString: '1級のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsmdan(
    divMultSplit: MultiplicationSplit.nsk1,
    divMultSource: MultiplicationSource.nsdan,
    denomination: .nisshou,
    displayString: '段位のかけ算',
    builder: MultiplicationProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk8(
    divMultSplit: DivisionSplit.k8,
    divMultSource: DivisionSource.nsk8,
    denomination: .nisshou,
    displayString: '8級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk7(
    divMultSplit: DivisionSplit.k7,
    divMultSource: DivisionSource.nsk7,
    denomination: .nisshou,
    displayString: '7級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk6(
    divMultSplit: DivisionSplit.k6,
    divMultSource: DivisionSource.nsk6,
    denomination: .nisshou,
    displayString: '6級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk5(
    divMultSplit: DivisionSplit.k5,
    divMultSource: DivisionSource.nsk5,
    denomination: .nisshou,
    displayString: '5級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk4(
    divMultSplit: DivisionSplit.k4,
    divMultSource: DivisionSource.nsk4,
    denomination: .nisshou,
    displayString: '4級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  ),
  nsdk3(
    divMultSplit: DivisionSplit.k3,
    divMultSource: DivisionSource.k7,
    denomination: .nisshou,
    displayString: '7級のわり算',
    builder: DivisionProblem.new,
    timeLimit: Duration(minutes: 10),
  );

  const DivMultLevel({
    required this.divMultSplit,
    required this.divMultSource,
    required this.denomination,
    required this.displayString,
    required this.builder,
    required this.timeLimit,
  });
  final DivMultSplit divMultSplit;
  final DivMultSource divMultSource;
  @override
  final PaperDenomination denomination;
  @override
  final String displayString;
  @override
  final Duration timeLimit;
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
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '10級のみとり算 (A)',
    timeLimit: Duration(minutes: 7),
  ),
  zsk10b(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 2},
      ],
    ],
    minusCount: 2,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '10級のみとり算 (B)',
    timeLimit: Duration(minutes: 7),
  ),
  zsk9(
    templates: [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 3},
      ],
    ],
    minusCount: 2,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '9級のみとり算',
    timeLimit: Duration(minutes: 7),
  ),
  zsk8(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 2,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '8級のみとり算',
    timeLimit: Duration(minutes: 7),
  ),
  zsk7(
    templates: [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 2},
      ],
    ],
    minusCount: 2,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '7級のみとり算',
    timeLimit: Duration(minutes: 7),
  ),
  zsk6(
    templates: [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 5},
      ],
    ],
    minusCount: 3,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '6級のみとり算',
    timeLimit: Duration(minutes: 7),
  ),
  zsk5(
    templates: [
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 3},
      ],
    ],
    minusCount: 3,
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '5級のみとり算',
    timeLimit: Duration(minutes: 7),
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
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5],
    repeat: 3,
    neverNegative: true,
    displayString: '4級のみとり算',
    timeLimit: Duration(minutes: 7),
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
    minusProblemsPerGroup: 1,
    denomination: .zenshuren,
    templateCountPerGroup: [3, 2],
    repeat: 3,
    neverNegative: true,
    displayString: '3級のみとり算',
    timeLimit: Duration(minutes: 7),
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
    minusProblemsPerGroup: 1,
    denomination: .zenshuren,
    templateCountPerGroup: [3, 2],
    repeat: 3,
    neverNegative: false,
    displayString: '2級のみとり算',
    timeLimit: Duration(minutes: 7),
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
    minusProblemsPerGroup: 1,
    denomination: .zenshuren,
    templateCountPerGroup: [3, 2],
    repeat: 3,
    neverNegative: false,
    displayString: '1級のみとり算',
    timeLimit: Duration(minutes: 7),
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
    minusProblemsPerGroup: 2,
    denomination: .zenshuren,
    templateCountPerGroup: [5, 5, 5, 5, 5, 5],
    repeat: 1,
    neverNegative: false,
    displayString: '段位のみとり算',
    timeLimit: Duration(minutes: 7),
  ),
  nsk9(
    templates: [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    minusCount: 1,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '10級/9級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk8(
    templates: [
      [
        {"digits": 2, "count": 8},
      ],
    ],
    minusCount: 2,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '8級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk7(
    templates: [
      [
        {"digits": 2, "count": 10},
      ],
    ],
    minusCount: 3,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '7級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk6(
    templates: [
      [
        {"digits": 3, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '6級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk5(
    templates: [
      [
        {"digits": 4, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    neverNegative: true,
    displayString: '5級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk4(
    templates: [
      [
        {"digits": 5, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '4級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  // // Minus generation doesn't work.
  // nskj3(
  //   templates: [
  //     [
  //       {"digits": 5, "count": 10},
  //     ],
  //     [
  //       {"digits": 6, "count": 10},
  //     ],
  //   ],
  //   minusCount: 4,
  //   minusProblemsPerGroup: 2,
  //   denomination: .nisshou,
  //   templateCountPerGroup: [5, 5],
  //   repeat: 1,
  //   displayString: '準3級みとり算',
  //   timeLimit: Duration(minutes: 10),
  // ),
  nsk3(
    templates: [
      [
        {"digits": 6, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '3級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nskj2(
    templates: [
      [
        {"digits": 7, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '準2級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk2(
    templates: [
      [
        {"digits": 8, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '2級みとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nskj1(
    templates: [
      [
        {"digits": 9, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '準1級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsk1(
    templates: [
      [
        {"digits": 10, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '1級のみとり算',
    timeLimit: Duration(minutes: 10),
  ),
  nsdan(
    templates: [
      [
        {"digits": 10, "count": 10},
      ],
    ],
    minusCount: 4,
    minusProblemsPerGroup: 2,
    denomination: .nisshou,
    templateCountPerGroup: [10],
    repeat: 1,
    displayString: '段位のみとり算',
    timeLimit: Duration(minutes: 10),
  );

  const MitoriLevel({
    required this.templates,
    required this.minusCount,
    this.minusProblemsPerGroup,
    required this.denomination,
    required this.templateCountPerGroup,
    required this.repeat,
    this.neverNegative,
    required this.displayString,
    required this.timeLimit,
  });
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final int? minusProblemsPerGroup;
  @override
  final PaperDenomination denomination;
  final List<int> templateCountPerGroup;
  final int repeat;
  final bool? neverNegative; // nisshou is always neverNegative
  @override
  final String displayString;
  @override
  final Duration timeLimit;
}

enum PaperDenomination {
  nisshou(passThreshold: 0.66),
  zenshuren(passThreshold: 0.7);

  const PaperDenomination({required this.passThreshold});
  final double passThreshold;
}

sealed class PaperProblemLevel {
  Duration get timeLimit;
  PaperDenomination get denomination;
  String get displayString;
}
