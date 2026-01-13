sealed class DivMultSource {
  const DivMultSource();
  List<Map<String, int>> get templates;
}

sealed class DivMultSplit {
  const DivMultSplit();
  dynamic get templates;
}

enum MultiplicationSplit implements DivMultSplit {
  k9({
    // easy
    3: [
      [2, 1],
    ],
  }),
  k8({
    // easy
    4: [
      [3, 1],
    ],
  }),
  k7({
    4: [
      [2, 2],
    ],
  }),
  k6({
    5: [
      [2, 3],
      [3, 2],
    ],
  }),
  k5({
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  }),
  k4({
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  }),
  k3({
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  }),
  k2({
    8: [
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
  }),
  k1({
    9: [
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
  }),
  dan({
    9: [
      // 5 problems, 11224
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
    10: [
      // 5 problems, 11224
      [4, 6],
      [5, 5],
      [5, 5],
      [6, 4],
    ],
    11: [
      // 5 problems, 11224
      [4, 7],
      [5, 6],
      [6, 5],
      [7, 4],
    ],
    12: [
      // (5 problems, 11555) * 3
      [5, 7],
      [6, 6],
      [6, 6],
      [7, 5],
    ],
  });

  const MultiplicationSplit(this.templates);
  final Map<int, List<List<int>>> templates;
}

const kyuuSpec = {
  'type2Count': 3,
  'type4Count': 1,
  'type5Count': 4,
  'totalCount': 15,
};

enum MultiplicationSource implements DivMultSource {
  k9([
    {"digits": 3, "problemCount": 15},
  ]),
  k8([
    {"digits": 4, "problemCount": 15},
  ]),
  k7([
    {"digits": 4, "problemCount": 15},
  ]),
  k6([
    {"digits": 5, "problemCount": 15},
  ]),
  k5([
    {"digits": 6, "problemCount": 15},
  ]),
  k4([
    {"digits": 7, "problemCount": 15},
  ]),
  k3([
    {"digits": 7, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 7, "problemCount": 8, "type5Count": 4},
  ]),
  k2([
    {"digits": 8, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 8, "problemCount": 8, "type5Count": 4},
  ]),
  k1([
    {"digits": 9, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 9, "problemCount": 8, "type5Count": 4},
  ]),
  dan([
    {"digits": 9, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 10, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 11, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
  ]);

  const MultiplicationSource(this.templates);
  final List<Map<String, int>> templates;
}

enum DivisionSplit implements DivMultSplit {
  k8({
    3: [
      [1, 2],
    ],
  }),
  k7({
    4: [
      [1, 3],
    ],
  }),
  k6({
    4: [
      [2, 2],
    ],
  }),
  k5({
    5: [
      [2, 3],
      [3, 2],
    ],
  }),
  k4({
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  }),
  k3({
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  }),
  k2({
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  }),
  k1({
    8: [
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
  }),
  dan({
    8: [
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
    9: [
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
    10: [
      [4, 6],
      [5, 5],
      [5, 5],
      [6, 4],
    ],
    11: [
      [4, 7],
      [5, 6],
      [6, 5],
      [7, 4],
    ],
  });

  const DivisionSplit(this.templates);
  final Map<int, List<List<int>>> templates;
}

enum DivisionSource implements DivMultSource {
  k8([
    {"digits": 3, "problemCount": 15},
  ]),
  k7([
    {"digits": 4, "problemCount": 15},
  ]),
  k6([
    {"digits": 4, "problemCount": 15},
  ]),
  k5([
    {"digits": 5, "problemCount": 15},
  ]),
  k4([
    {"digits": 6, "problemCount": 15},
  ]),
  k3([
    {"digits": 6, "problemCount": 7, "type2Count": 2, "type3Count": 2},
    {"digits": 6, "problemCount": 8, "type4Count": 2, "type5Count": 2},
  ]),
  k2([
    {"digits": 7, "problemCount": 7, "type2Count": 2, "type3Count": 2},
    {"digits": 7, "problemCount": 8, "type4Count": 2, "type5Count": 2},
  ]),
  k1([
    {"digits": 8, "problemCount": 7, "type2Count": 2, "type3Count": 2},
    {"digits": 8, "problemCount": 8, "type4Count": 2, "type5Count": 2},
  ]),
  dan([
    {"digits": 8, "problemCount": 5, "type2Count": 1, "type3Count": 2},
    {"digits": 9, "problemCount": 5, "type2Count": 1, "type3Count": 2},
    {"digits": 10, "problemCount": 5, "type2Count": 1, "type3Count": 2},
    {"digits": 10, "problemCount": 5, "type4Count": 1, "type5Count": 2},
    {"digits": 11, "problemCount": 5, "type4Count": 1, "type5Count": 2},
    {"digits": 11, "problemCount": 5, "type4Count": 1, "type5Count": 2},
  ]);

  const DivisionSource(this.templates);
  final List<Map<String, int>> templates;
}
