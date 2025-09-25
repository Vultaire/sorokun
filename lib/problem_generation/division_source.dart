final Map<String, dynamic> digitSplit = {
  "8kyuu": {
    3: [
      [1, 2],
    ],
  },
  "7kyuu": {
    4: [
      [1, 3],
    ],
  },
  "6kyuu": {
    4: [
      [2, 2],
    ],
  },
  "5kyuu": {
    5: [
      [2, 3],
      [3, 2],
    ],
  },
  "4kyuu": {
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  },
  "3kyuu": {
    6: [
      [2, 4],
      [3, 3],
      [3, 3],
      [4, 2],
    ],
  },
  "2kyuu": {
    7: [
      [2, 5],
      [3, 4],
      [4, 3],
      [5, 2],
    ],
  },
  "1kyuu": {
    8: [
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
  },
  "dan": {
    8: [
      // 5 problems, 11233
      [3, 5],
      [4, 4],
      [4, 4],
      [5, 3],
    ],
    9: [
      // 5 problems, 11233
      [3, 6],
      [4, 5],
      [5, 4],
      [6, 3],
    ],
    10: [
      // 5 problems, 11233; 5 integer problems, 11455
      [4, 6],
      [5, 5],
      [5, 5],
      [6, 4],
    ],
    11: [
      // 5 problems, 11455; 5 problems, 11455
      [4, 7],
      [5, 6],
      [6, 5],
      [7, 4],
    ],
  },
};

final Map<String, Map<String, int>> divisionSource = {
  'noDecimal': {
    'type2Count': 0,
    'type3Count': 0,
    'type4Count': 0,
    'type5Count': 0,
    'totalCount': 15,
  },
  '3kyuu': {
    'type2Count': 2,
    'type3Count': 2,
    'type4Count': 2,
    'type5Count': 2,
    'totalCount': 15,
  },
  '2kyuu': {
    'type2Count': 2,
    'type3Count': 2,
    'type4Count': 2,
    'type5Count': 2,
    'totalCount': 15,
  },
  '1kyuu': {
    'type2Count': 2,
    'type3Count': 2,
    'type4Count': 2,
    'type5Count': 2,
    'totalCount': 15,
  },
  'dan': {
    'type2Count': 2,
    'type3Count': 2,
    'type4Count': 2,
    'type5Count': 2,
    'totalCount': 30,
  },
};
