import 'dart:math';

import 'package:soroban_app/problem_generation/helpers.dart';

class MitoriProblem {
  List<int> problem;
  MitoriProblem(this.problem);

  List<String> get formattedProblem =>
      problem.map((number) => formatWithCommas(number.toString())).toList();
  String get formattedAnswer =>
      formatWithCommas(problem.reduce((a, b) => a + b).toString());

  set newProblem(List<int> list) {
    problem = list;
  }
}

List<int> generateMitoriProblemFromDigitList(List<int> digitList, Random rand) {
  final bool hasLargeRows = digitList.any((d) => d > 10);
  int sum = digitList.fold(0, (a, b) => a + b);
  List<int> pool = _generatePool(sum, rand, digitList);
  for (int attempt = 0; attempt < 100; attempt++) {
    pool.shuffle(rand);
    List<List<int>> array = _buildInitialArray(digitList, pool);
    if (_fixViolations(
      array,
      rand,
      maxIterations: 10000,
      hasLargeRows: hasLargeRows,
    )) {
      return array.map((row) {
        final unreversed = row.reversed;
        return int.parse(unreversed.join());
      }).toList();
    }
  }
  throw Exception('Cannot satisfy constraints after 100 attempts');
}

List<List<int>> _buildInitialArray(List<int> input, List<int> pool) {
  List<List<int>> array = [];
  int poolIndex = 0;

  for (int rowIdx = 0; rowIdx < input.length; rowIdx++) {
    int rowLength = input[rowIdx];
    List<int> row = [];

    for (int col = 0; col < rowLength; col++) {
      row.add(pool[poolIndex++]);
    }

    array.add(row);
  }

  return array;
}

bool _fixViolations(
  List<List<int>> array,
  Random random, {
  required int maxIterations,
  required bool hasLargeRows,
}) {
  int iterations = 0;
  while (iterations < maxIterations) {
    List<Violation> violations = _findViolations(
      array,
      hasLargeRows: hasLargeRows,
    );
    if (violations.isEmpty) return true;
    iterations++;
    Violation violation = violations[random.nextInt(violations.length)];
    if (_tryFixViolation(array, violation, random)) continue;
    if (iterations % 100 == 0) _randomSwap(array, random);
  }
  return false;
}

List<Violation> _findViolations(
  List<List<int>> array, {
  required bool hasLargeRows,
}) {
  List<Violation> violations = [];
  for (int row = 0; row < array.length; row++) {
    if (hasLargeRows) {
      // Check adjacent duplicates instead of row duplicates
      for (int col = 0; col < array[row].length - 1; col++) {
        if (array[row][col] == array[row][col + 1]) {
          violations.add(
            Violation(
              type: ViolationType.adjacentDuplicate,
              row: row,
              col: col,
              digit: array[row][col],
            ),
          );
        }
      }
    } else {
      // Check for duplicates within row
      Set<int> seen = {};
      for (int col = 0; col < array[row].length; col++) {
        int digit = array[row][col];
        if (seen.contains(digit)) {
          violations.add(
            Violation(
              type: ViolationType.rowDuplicate,
              row: row,
              col: col,
              digit: digit,
            ),
          );
        }
        seen.add(digit);
      }
    }

    // Check last column for zero
    if (array[row].isNotEmpty && array[row].last == 0) {
      violations.add(
        Violation(
          type: ViolationType.lastColZero,
          row: row,
          col: array[row].length - 1,
          digit: 0,
        ),
      );
    }

    // Check vertical constraint
    if (row > 0) {
      for (
        int col = 0;
        col < array[row].length && col < array[row - 1].length;
        col++
      ) {
        if (array[row][col] == array[row - 1][col]) {
          violations.add(
            Violation(
              type: ViolationType.verticalDuplicate,
              row: row,
              col: col,
              digit: array[row][col],
            ),
          );
        }
      }
    }
  }
  return violations;
}

bool _tryFixViolation(
  List<List<int>> array,
  Violation violation,
  Random random,
) {
  // Try swapping with other positions in the same row first
  int row = violation.row;
  int col = violation.col;

  List<int> positions = List.generate(array[row].length, (i) => i);
  positions.shuffle(random);

  for (int otherCol in positions) {
    if (otherCol == col) continue;

    // Try swap
    _swap(array, row, col, row, otherCol);

    if (_isValidAfterSwap(array, row, col, row, otherCol)) {
      return true; // Swap fixed it!
    }

    // Undo swap
    _swap(array, row, col, row, otherCol);
  }

  // Try swapping with positions in other rows
  for (int otherRow = 0; otherRow < array.length; otherRow++) {
    if (otherRow == row) continue;

    List<int> cols = List.generate(array[otherRow].length, (i) => i);
    cols.shuffle(random);

    for (int otherCol in cols.take(5)) {
      // Only try a few per row
      // Try swap
      _swap(array, row, col, otherRow, otherCol);

      if (_isValidAfterSwap(array, row, col, otherRow, otherCol)) {
        return true; // Swap fixed it!
      }

      // Undo swap
      _swap(array, row, col, otherRow, otherCol);
    }
  }

  return false;
}

void _swap(List<List<int>> array, int r1, int c1, int r2, int c2) {
  int temp = array[r1][c1];
  array[r1][c1] = array[r2][c2];
  array[r2][c2] = temp;
}

bool _isValidAfterSwap(List<List<int>> array, int r1, int c1, int r2, int c2) {
  // Check all constraints for the affected positions
  return _isPositionValid(array, r1, c1) && _isPositionValid(array, r2, c2);
}

bool _isPositionValid(List<List<int>> array, int row, int col) {
  int digit = array[row][col];

  // Check row uniqueness
  for (int c = 0; c < array[row].length; c++) {
    if (c != col && array[row][c] == digit) {
      return false;
    }
  }

  // Check last column constraint
  if (col == array[row].length - 1 && digit == 0) {
    return false;
  }

  // Check vertical constraint (above)
  if (row > 0 && col < array[row - 1].length) {
    if (array[row - 1][col] == digit) {
      return false;
    }
  }

  // Check vertical constraint (below)
  if (row < array.length - 1 && col < array[row + 1].length) {
    if (array[row + 1][col] == digit) {
      return false;
    }
  }

  return true;
}

void _randomSwap(List<List<int>> array, Random random) {
  // Make a random swap to escape local minimum
  int r1 = random.nextInt(array.length);
  int c1 = random.nextInt(array[r1].length);
  int r2 = random.nextInt(array.length);
  int c2 = random.nextInt(array[r2].length);

  _swap(array, r1, c1, r2, c2);
}

List<int> _generatePool(int sum, Random random, List<int> input) {
  final bool allOnes = input.every((len) => len == 1);

  final List<int> digits = allOnes
      ? [1, 2, 3, 4, 5, 6, 7, 8, 9]
      : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  final int base = digits.length;

  final int completeSets = sum ~/ base;
  final int remainder = sum % base;

  final List<int> pool = [];

  // Add full sets
  for (int i = 0; i < completeSets; i++) {
    pool.addAll(digits);
  }

  // Add remainder
  if (remainder > 0) {
    final shuffled = List<int>.from(digits)..shuffle(random);
    pool.addAll(shuffled.take(remainder));
  }

  return pool;
}

class Violation {
  final ViolationType type;
  final int row;
  final int col;
  final int digit;

  Violation({
    required this.type,
    required this.row,
    required this.col,
    required this.digit,
  });
}

enum ViolationType {
  rowDuplicate,
  adjacentDuplicate,
  verticalDuplicate,
  lastColZero,
}
