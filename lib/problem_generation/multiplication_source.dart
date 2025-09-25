final Map<String, dynamic> digitSplit = {
  "9kyuu": {
    // easy
    3: [
      [2, 1],
    ],
  },
  "8kyuu": {
    // easy
    4: [
      [3, 1],
    ],
  },
  "7kyuu": {
    4: [
      [2, 2],
    ],
  },
  "6kyuu": {
    5: [
      [2, 3],
      [3, 2],
    ],
  },
  "5kyuu": {
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  },
  "4kyuu": {
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  },
  "3kyuu": {
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  },
  "2kyuu": {
    8: [
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
  },
  "1kyuu": {
    9: [
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
  },
  "dan": {
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
  },
};

const kyuuSpec = {
  'type2Count': 3,
  'type4Count': 1,
  'type5Count': 4,
  'totalCount': 15,
};

final Map<String, List<Map<String, dynamic>>> multiplicationSource = {
  "9kyuu": [
    {"digits": 3, "problemCount": 15},
  ],
  "8kyuu": [
    {"digits": 4, "problemCount": 15},
  ],
  "7kyuu": [
    {"digits": 4, "problemCount": 15},
  ],
  "6kyuu": [
    {"digits": 5, "problemCount": 15},
  ],
  "5kyuu": [
    {"digits": 6, "problemCount": 15},
  ],
  "4kyuu": [
    {"digits": 7, "problemCount": 15},
  ],
  "3kyuu": [
    {"digits": 7, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 7, "problemCount": 8, "type5Count": 4},
  ],
  "2kyuu": [
    {"digits": 8, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 8, "problemCount": 8, "type5Count": 4},
  ],
  "1kyuu": [
    {"digits": 9, "problemCount": 7, "type2Count": 3, "type4Count": 1},
    {"digits": 9, "problemCount": 8, "type5Count": 4},
  ],
  "dan": [
    {"digits": 9, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 10, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 11, "problemCount": 5, "type2Count": 2, "type4Count": 1},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
    {"digits": 12, "problemCount": 5, "type5Count": 3},
  ],
};
