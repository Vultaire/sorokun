sealed class DivMultSource {
  const DivMultSource();
  List<Map<String, dynamic>> get templates;
}

enum Split {
  threeDigitA({
    // easy
    3: [
      [2, 1],
    ],
  }),
  threeDigitB({
    3: [
      [1, 2],
    ],
  }),
  fourDigitA({
    // easy
    4: [
      [3, 1],
    ],
  }),
  fourDigitB({
    4: [
      [2, 2],
    ],
  }),
  fourDigitC({
    4: [
      [1, 3],
    ],
  }),
  nsdakj3({
    3: [
      [1, 2],
    ],
    4: [
      [1, 3],
    ],
  }),
  nsmakj3({
    3: [
      [2, 1],
    ],
    4: [
      [3, 1],
    ],
  }),
  nsdakj2({
    0: [
      // Actually four
      [1, 3],
    ],
    4: [
      [2, 2],
    ],
  }),
  nsmakj2({
    0: [
      // Actually four
      [3, 1],
    ],
    4: [
      [2, 2],
    ],
  }),
  nsakj1({
    4: [
      [2, 2],
    ],
    5: [
      [2, 3],
      [3, 2],
    ],
  }),
  nsadan({
    5: [
      [2, 3],
      [3, 2],
    ],
    6: [
      [2, 4],
      [3, 3],
      [4, 2],
    ],
    7: [
      [3, 4],
      [4, 3],
    ],
  }),
  fiveDigit({
    5: [
      [2, 3],
      [3, 2],
    ],
  }),
  sixDigit({
    6: [
      [2, 4],
      [3, 3],
      [4, 2],
    ],
  }),
  sevenDigit({
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  }),
  eightDigit({
    8: [
      [3, 5],
      [4, 4],
      [5, 3],
    ],
  }),
  nineDigit({
    9: [
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
  }),
  tenDigit({
    10: [
      [4, 6],
      [5, 5],
      [6, 4],
    ],
  }),
  elevenDigit({
    11: [
      [5, 6],
      [6, 5],
      [7, 4],
    ],
  }),
  zsmdan({
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
  }),
  zsddan({
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

  const Split(this.templates);

  final Map<int, List<List<int>>> templates;
}

enum MultiplicationSource implements DivMultSource {
  zsk9([
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
  zsk8([
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
  zsk7([
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
  zsk6([
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
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
  ]),
  zsk5([
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
  zsk4([
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
  nsak4([
    {
      "digits": 3,
      "problemCount": 30,
      "splitCount": [30],
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
  zsk3([
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
  nsakj3([
    {
      "digits": 3,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nskj3([
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
  zsk2([
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
  nsakj2([
    {
      "digits": 0,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nskj2([
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
  nsak2([
    {
      "digits": 4,
      "problemCount": 30,
      "splitCount": [30],
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
  zsk1([
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
  nsakj1([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
  ]),
  nskj1([
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
  nsak1([
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
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
  nsadan([
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
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
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [2, 3],
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

enum DivisionSource implements DivMultSource {
  nsk8([
    {
      "digits": 3,
      "problemCount": 10,
      "splitCount": [10],
    },
  ]),
  zsk8([
    {
      "digits": 3,
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
  zsk7([
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

  zsk6([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsk5([
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
  ]),
  zsk5([
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
  nsak4([
    {
      "digits": 3,
      "problemCount": 30,
      "splitCount": [30],
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
  zsk4([
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
  nsajk3([
    {
      "digits": 3,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsjk3([
    {
      "digits": 6,
      "problemCount": 10,
      "type2Count": 3,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 6,
      "problemCount": 10,
      "type4Count": 3,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsak3([
    {
      "digits": 4,
      "problemCount": 30,
      "splitCount": [30],
    },
  ]),
  nsk3([
    {
      "digits": 6,
      "problemCount": 10,
      "type2Count": 2,
      "type3Count": 2,
      "type6Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 6,
      "problemCount": 10,
      "type4Count": 4,
      "type5Count": 1,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  zsk3([
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
  nsakj2([
    {
      "digits": 0,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
  ]),
  nsjk2([
    {
      "digits": 7,
      "problemCount": 10,
      "type2Count": 2,
      "type3Count": 2,
      "type6Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 7,
      "problemCount": 10,
      "type4Count": 4,
      "type5Count": 1,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsak2([
    {
      "digits": 4,
      "problemCount": 30,
      "splitCount": [30],
    },
  ]),
  nsk2([
    {
      "digits": 8,
      "problemCount": 10,
      "type2Count": 2,
      "type3Count": 2,
      "type6Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 8,
      "problemCount": 10,
      "type4Count": 3,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  zsk2([
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
  nsakj1([
    {
      "digits": 4,
      "problemCount": 15,
      "splitCount": [15],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
  ]),
  nsjk1([
    {
      "digits": 9,
      "problemCount": 10,
      "type2Count": 2,
      "type3Count": 2,
      "type7Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 9,
      "problemCount": 10,
      "type4Count": 3,
      "type5Count": 2,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  nsak1([
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
  ]),
  nsk1([
    {
      "digits": 10,
      "problemCount": 10,
      "type2Count": 2,
      "type3Count": 2,
      "type7Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type4Count": 2,
      "type5Count": 3,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  zsk1([
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
  nsadan([
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 5,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
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
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [2, 3],
    },
    {
      "digits": 7,
      "problemCount": 5,
      "splitCount": [3, 2],
    },
  ]),
  nsdan([
    {
      "digits": 10,
      "problemCount": 10,
      "type2Count": 1,
      "type3Count": 3,
      "type7Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type2Count": 1,
      "type3Count": 3,
      "type7Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type2Count": 1,
      "type3Count": 3,
      "type7Count": 1,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type4Count": 1,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type4Count": 1,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
    {
      "digits": 10,
      "problemCount": 10,
      "type4Count": 1,
      "type5Count": 4,
      "intRound": true,
      "splitCount": [1, 8, 1],
    },
  ]),
  dzsan([
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
