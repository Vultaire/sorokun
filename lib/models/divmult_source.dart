sealed class DivMultSource {
  const DivMultSource();
  List<Map<String, dynamic>> get templates;
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
  nsjk1({
    // TODO: Clean this up
    10: [
      [4, 6],
      [5, 5],
      [6, 4],
    ],
  }),
  nsk1({
    11: [
      [5, 6],
      [6, 5],
      [7, 4],
    ],
  }),
  dan({
    9: [
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
    10: [
      [4, 6],
      [5, 5],
      [6, 4],
    ],
    11: [
      [4, 7],
      [5, 6],
      [6, 5],
      [7, 4],
    ],
    12: [
      [5, 7],
      [6, 6],
      [7, 5],
    ],
  });

  const MultiplicationSplit(this.templates);

  @override
  final Map<int, List<List<int>>> templates;
}

enum MultiplicationSource implements DivMultSource {
  k9([
    {
      "digits": 3,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk9([
    {
      "digits": 3,
      "problemCount": 20,
      "splitCount": [20],
    },
  ]),
  k8([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk8([
    {
      "digits": 4,
      "problemCount": 10,
      "splitCount": [10],
    },
  ]),
  k7([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk7([
    {
      "digits": 4,
      "problemCount": 10,
      "splitCount": [10],
    },
  ]),
  k6([
    {
      "digits": 5,
      "problemCount": 7,
      "splitCount": [3, 4],
    },
    {
      "digits": 5,
      "problemCount": 8,
      "splitCount": [4, 4],
    },
  ]),
  nsk6([
    {
      "digits": 5,
      "problemCount": 10,
      "splitCount": [5, 5],
    },
    {
      "digits": 5,
      "problemCount": 10,
      "splitCount": [5, 5],
    },
  ]),
  k5([
    {
      "digits": 6,
      "problemCount": 7,
      "splitCount": [1, 4, 2],
    },
    {
      "digits": 6,
      "problemCount": 8,
      "splitCount": [2, 5, 1],
    },
  ]),
  nsk5([
    {
      "digits": 6,
      "problemCount": 10,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 6,
      "problemCount": 10,
      "splitCount": [1, 8, 1],
    },
  ]),
  k4([
    {
      "digits": 7,
      "problemCount": 7,
      "splitCount": [1, 2, 3, 1],
    },
    {
      "digits": 7,
      "problemCount": 8,
      "splitCount": [1, 3, 3, 1],
    },
  ]),
  nsk4([
    {
      "digits": 7,
      "problemCount": 10,
      "splitCount": [0, 1, 8, 1],
    },
    {
      "digits": 7,
      "problemCount": 10,
      "splitCount": [0, 1, 8, 1],
    },
  ]),
  k3([
    {
      "digits": 7,
      "problemCount": 7,
      "type2Count": 3,
      "type4Count": 1,
      "splitCount": [1, 2, 3, 1],
    },
    {
      "digits": 7,
      "problemCount": 8,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [1, 3, 3, 1],
    },
  ]),
  nsjk3([
    {
      "digits": 7,
      "problemCount": 10,
      "type2Count": 2,
      "type5Count": 1,
      "splitCount": [0, 1, 8, 1],
    },
    {
      "digits": 7,
      "problemCount": 10,
      "type5Count": 3,
      "intRound": true,
      "splitCount": [0, 1, 8, 1],
    },
  ]),
  nsk3([
    {
      "digits": 7,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [0, 1, 8, 1],
    },
    {
      "digits": 7,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [0, 1, 8, 1],
    },
  ]),
  k2([
    {
      "digits": 8,
      "problemCount": 7,
      "type2Count": 3,
      "type4Count": 1,
      "splitCount": [1, 4, 2],
    },
    {
      "digits": 8,
      "problemCount": 8,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [2, 5, 1],
    },
  ]),
  nsjk2([
    {
      "digits": 8,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 8,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsk2([
    {
      "digits": 9,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 9,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  k1([
    {
      "digits": 9,
      "problemCount": 7,
      "type2Count": 3,
      "type4Count": 1,
      "splitCount": [1, 2, 3, 1],
    },
    {
      "digits": 9,
      "problemCount": 8,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [1, 3, 3, 1],
    },
  ]),
  nsjk1([
    {
      "digits": 10,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsk1([
    {
      "digits": 11,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsdan([
    {
      "digits": 11,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type2Count": 3,
      "type5Count": 2,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 11,
      "problemCount": 10,
      "type5Count": 5,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  zsdan([
    {
      "digits": 9,
      "problemCount": 5,
      "type2Count": 2,
      "type4Count": 1,
      "splitCount": [1, 1, 2, 1],
    },
    {
      "digits": 10,
      "problemCount": 5,
      "type2Count": 2,
      "type4Count": 1,
      "splitCount": [1, 3, 1],
    },
    {
      "digits": 11,
      "problemCount": 5,
      "type2Count": 2,
      "type4Count": 1,
      "splitCount": [1, 1, 2, 1],
    },
    {
      "digits": 11,
      "problemCount": 5,
      "type5Count": 3,
      "intRound": true,
      "splitCount": [1, 2, 1, 1],
    },
    {
      "digits": 12,
      "problemCount": 5,
      "type5Count": 3,
      "intRound": true,
      "splitCount": [2, 2, 1],
    },
    {
      "digits": 12,
      "problemCount": 5,
      "type5Count": 3,
      "intRound": true,
      "splitCount": [1, 2, 2],
    },
  ]);

  const MultiplicationSource(this.templates);

  @override
  final List<Map<String, dynamic>> templates;
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
      [4, 2],
    ],
  }),
  k3({
    6: [
      [2, 4],
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
      [5, 3],
    ],
  }),
  dan({
    8: [
      [3, 5],
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

  @override
  final Map<int, List<List<int>>> templates;
}

enum DivisionSource implements DivMultSource {
  nsk8([
    {
      "digits": 3,
      "problemCount": 10,
      "splitCount": [10],
    },
  ]),
  k8([
    {
      "digits": 3,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk7([
    {
      "digits": 3,
      "problemCount": 10,
      "splitCount": [10],
    },
  ]),
  k7([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk6([
    {
      "digits": 4,
      "problemCount": 20,
      "splitCount": [20],
    },
  ]),
  k6([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk5([
    {
      "digits": 5,
      "problemCount": 10,
      "splitCount": [5, 5],
    },
    {
      "digits": 5,
      "problemCount": 10,
      "splitCount": [5, 5],
    },
  ]),
  k5([
    {
      "digits": 5,
      "problemCount": 7,
      "splitCount": [4, 3],
    },
    {
      "digits": 5,
      "problemCount": 8,
      "splitCount": [4, 4],
    },
  ]),
  nsk4([
    {
      "digits": 6,
      "problemCount": 10,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 6,
      "problemCount": 10,
      "splitCount": [1, 8, 1],
    },
  ]),
  k4([
    {
      "digits": 6,
      "problemCount": 7,
      "splitCount": [1, 4, 2],
    },
    {
      "digits": 6,
      "problemCount": 8,
      "splitCount": [2, 5, 1],
    },
  ]),
  nsk3([
    {
      "digits": 6,
      "problemCount": 10,
      "type2Count": 1,
      "type3Count": 3,
      "type6Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 6,
      "problemCount": 10,
      "type4Count": 4,
      "type5Count": 1,
      "splitCount": [1, 8, 1],
    },
  ]),
  k3([
    {
      "digits": 6,
      "problemCount": 7,
      "type2Count": 2,
      "type3Count": 2,
      "splitCount": [1, 4, 2],
    },
    {
      "digits": 6,
      "problemCount": 8,
      "type4Count": 2,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [2, 5, 1],
    },
  ]),
  k2([
    {
      "digits": 7,
      "problemCount": 7,
      "type2Count": 2,
      "type3Count": 2,
      "splitCount": [1, 3, 2, 1],
    },
    {
      "digits": 7,
      "problemCount": 8,
      "type4Count": 2,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 3, 3, 1],
    },
  ]),
  k1([
    {
      "digits": 8,
      "problemCount": 7,
      "type2Count": 2,
      "type3Count": 2,
      "splitCount": [2, 4, 1],
    },
    {
      "digits": 8,
      "problemCount": 8,
      "type4Count": 2,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 5, 2],
    },
  ]),
  dan([
    {
      "digits": 8,
      "problemCount": 5,
      "type2Count": 1,
      "type3Count": 2,
      "splitCount": [1, 3, 1],
    },
    {
      "digits": 9,
      "problemCount": 5,
      "type2Count": 1,
      "type3Count": 2,
      "splitCount": [1, 2, 1, 1],
    },
    {
      "digits": 10,
      "problemCount": 5,
      "type2Count": 1,
      "type3Count": 2,
      "splitCount": [1, 3, 1],
    },
    {
      "digits": 10,
      "problemCount": 5,
      "type4Count": 1,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 3, 1],
    },
    {
      "digits": 11,
      "problemCount": 5,
      "type4Count": 1,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 1, 2, 1],
    },
    {
      "digits": 11,
      "problemCount": 5,
      "type4Count": 1,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 2, 1, 1],
    },
  ]);

  const DivisionSource(this.templates);

  @override
  final List<Map<String, dynamic>> templates;
}
