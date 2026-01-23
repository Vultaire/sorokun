import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel implements PaperProblemLevel {
  mk9(
    MultiplicationSplit.k9,
    MultiplicationSource.k9,
    '9級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk8(
    MultiplicationSplit.k8,
    MultiplicationSource.k8,
    '8級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk7(
    MultiplicationSplit.k7,
    MultiplicationSource.k7,
    '7級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk6(
    MultiplicationSplit.k6,
    MultiplicationSource.k6,
    '6級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk5(
    MultiplicationSplit.k5,
    MultiplicationSource.k5,
    '5級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk4(
    MultiplicationSplit.k4,
    MultiplicationSource.k4,
    '4級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk3(
    MultiplicationSplit.k3,
    MultiplicationSource.k3,
    '3級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk2(
    MultiplicationSplit.k2,
    MultiplicationSource.k2,
    '2級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mk1(
    MultiplicationSplit.k1,
    MultiplicationSource.k1,
    '1級のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  mdan(
    MultiplicationSplit.dan,
    MultiplicationSource.dan,
    '段位のかけ算',
    MultiplicationProblem.new,
    Duration(minutes: 7),
  ),
  dk8(
    DivisionSplit.k8,
    DivisionSource.k8,
    '8級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk7(
    DivisionSplit.k7,
    DivisionSource.k7,
    '7級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk6(
    DivisionSplit.k6,
    DivisionSource.k6,
    '6級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk5(
    DivisionSplit.k5,
    DivisionSource.k5,
    '5級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk4(
    DivisionSplit.k4,
    DivisionSource.k4,
    '4級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk3(
    DivisionSplit.k3,
    DivisionSource.k3,
    '3級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk2(
    DivisionSplit.k2,
    DivisionSource.k2,
    '2級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  dk1(
    DivisionSplit.k1,
    DivisionSource.k1,
    '1級のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  ),
  ddan(
    DivisionSplit.dan,
    DivisionSource.dan,
    '段位のわり算',
    DivisionProblem.new,
    Duration(minutes: 7),
  );

  const DivMultLevel(
    this.divMultSplit,
    this.divMultSource,
    this.displayString,
    this.builder,

    this.timeLimit,
  );
  final DivMultSplit divMultSplit;
  final DivMultSource divMultSource;
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
        {"digits": 4, "count": 10},
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
  final Denomination denomination;
  final List<int> templateCountPerGroup;
  final int repeat;
  final bool? neverNegative; // nisshou is always neverNegative

  @override
  final String displayString;
  @override
  final Duration timeLimit;
}

enum Denomination { nisshou, zenshuren }

sealed class PaperProblemLevel {
  String get displayString;
  Duration get timeLimit;
}
