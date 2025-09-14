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
    12: [
      [5, 7],
      [6, 6],
      [6, 6],
      [7, 5],
    ],
  },
};

final Map<String, Map<String, int>> multiplicationSource = {
  'noDecimal': {
    'type2Count': 0,
    'type3Count': 0,
    'type4Count': 0,
    'totalCount': 15,
  },
  '3kyuu': {
    'type2Count': 3,
    'type3Count': 1,
    'type4Count': 4,
    'totalCount': 15,
  },
  '2kyuu': {
    'type2Count': 3,
    'type3Count': 1,
    'type4Count': 4,
    'totalCount': 15,
  },
  '1kyuu': {
    'type2Count': 3,
    'type3Count': 1,
    'type4Count': 4,
    'totalCount': 15,
  },
  'dan': {'type2Count': 2, 'type3Count': 2, 'type4Count': 2, 'totalCount': 15},
};
