import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel implements ProblemLevel {
  mk9(
    MultiplicationSplit.k9,
    MultiplicationSource.k9,
    '9級のかけ算',
    MultiplicationProblem.new,
  ),
  mk8(
    MultiplicationSplit.k8,
    MultiplicationSource.k8,
    '8級のかけ算',
    MultiplicationProblem.new,
  ),
  mk7(
    MultiplicationSplit.k7,
    MultiplicationSource.k7,
    '7級のかけ算',
    MultiplicationProblem.new,
  ),
  mk6(
    MultiplicationSplit.k6,
    MultiplicationSource.k6,
    '6級のかけ算',
    MultiplicationProblem.new,
  ),
  mk5(
    MultiplicationSplit.k5,
    MultiplicationSource.k5,
    '5級のかけ算',
    MultiplicationProblem.new,
  ),
  mk4(
    MultiplicationSplit.k4,
    MultiplicationSource.k4,
    '4級のかけ算',
    MultiplicationProblem.new,
  ),
  mk3(
    MultiplicationSplit.k3,
    MultiplicationSource.k3,
    '3級のかけ算',
    MultiplicationProblem.new,
  ),
  mk2(
    MultiplicationSplit.k2,
    MultiplicationSource.k2,
    '2級のかけ算',
    MultiplicationProblem.new,
  ),
  mk1(
    MultiplicationSplit.k1,
    MultiplicationSource.k1,
    '1級のかけ算',
    MultiplicationProblem.new,
  ),
  mdan(
    MultiplicationSplit.dan,
    MultiplicationSource.dan,
    '段位のかけ算',
    MultiplicationProblem.new,
  ),
  dk8(DivisionSplit.k8, DivisionSource.k8, '8級のわり算', DivisionProblem.new),
  dk7(DivisionSplit.k7, DivisionSource.k7, '7級のわり算', DivisionProblem.new),
  dk6(DivisionSplit.k6, DivisionSource.k6, '6級のわり算', DivisionProblem.new),
  dk5(DivisionSplit.k5, DivisionSource.k5, '5級のわり算', DivisionProblem.new),
  dk4(DivisionSplit.k4, DivisionSource.k4, '4級のわり算', DivisionProblem.new),
  dk3(DivisionSplit.k3, DivisionSource.k3, '3級のわり算', DivisionProblem.new),
  dk2(DivisionSplit.k2, DivisionSource.k2, '2級のわり算', DivisionProblem.new),
  dk1(DivisionSplit.k1, DivisionSource.k1, '1級のわり算', DivisionProblem.new),
  ddan(DivisionSplit.dan, DivisionSource.dan, '段位のわり算', DivisionProblem.new);

  const DivMultLevel(
    this.divMultSplit,
    this.divMultSource,
    this.displayString,
    this.builder,
  );
  final DivMultSplit divMultSplit;
  final DivMultSource divMultSource;
  @override
  final String displayString;
  final Function builder;
}

enum MitoriLevel implements ProblemLevel {
  k10a(
    [
      [
        {"digits": 1, "count": 6},
      ],
    ],
    2,
    [5],
    3,
    true,
    '10級のみとり算 (A)',
  ),
  k10b(
    [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 2},
      ],
    ],
    2,
    [5],
    3,
    true,
    '10級のみとり算 (B)',
  ),
  k9(
    [
      [
        {"digits": 1, "count": 2},
        {"digits": 2, "count": 3},
      ],
    ],
    2,
    [5],
    3,
    true,
    '9級のみとり算',
  ),
  k8(
    [
      [
        {"digits": 2, "count": 5},
      ],
    ],
    2,
    [5],
    3,
    true,
    '8級のみとり算',
  ),
  k7(
    [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 2},
      ],
    ],
    2,
    [5],
    3,
    true,
    '7級のみとり算',
  ),
  k6(
    [
      [
        {"digits": 2, "count": 2},
        {"digits": 3, "count": 5},
      ],
    ],
    3,
    [5],
    3,
    true,
    '6級のみとり算',
  ),
  k5(
    [
      [
        {"digits": 3, "count": 4},
        {"digits": 4, "count": 3},
      ],
    ],
    3,
    [5],
    3,
    true,
    '5級のみとり算',
  ),
  k4(
    [
      [
        {"digits": 3, "count": 2},
        {"digits": 4, "count": 3},
        {"digits": 5, "count": 2},
      ],
    ],
    3,
    [5],
    3,
    true,
    '4級のみとり算',
  ),
  k3(
    [
      [
        {"digits": 3, "count": 3},
        {"digits": 4, "count": 2},
        {"digits": 5, "count": 3},
      ],
      [
        {"digits": 4, "count": 8},
      ],
    ],
    3,
    [3, 2],
    3,
    true,
    '3級のみとり算',
  ),
  k2(
    [
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
    3,
    [3, 2],
    3,
    false,
    '2級のみとり算',
  ),
  k1(
    [
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
    3,
    [3, 2],
    3,
    false,
    '1級のみとり算',
  ),
  dan(
    [
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
    2,
    [5, 5, 5, 5, 5, 5],
    1,
    false,
    '段位のみとり算',
  );

  const MitoriLevel(
    this.templates,
    this.minusCount,
    this.templateCountPerGroup,
    this.repeat,
    this.neverNegative,
    this.displayString,
  );
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final List<int> templateCountPerGroup;
  final int repeat;
  final bool neverNegative;
  @override
  final String displayString;
}

sealed class ProblemLevel {
  String get displayString;
}
