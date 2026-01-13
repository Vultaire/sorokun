enum PaperSource {
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
  );

  const PaperSource(
    this.templates,
    this.minusCount,
    this.templateCountPerGroup,
    this.repeat,
    this.neverNegative,
  );
  final List<List<Map<String, int>>> templates;
  final int minusCount;
  final List<int> templateCountPerGroup;
  final int repeat;
  final bool neverNegative;
}
