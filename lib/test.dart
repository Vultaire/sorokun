import 'dart:math';

List<List<int>> generate2DArray(List<int> input) {
  final random = Random();

  // Calculate sum and generate pool
  int sum = input.fold(0, (a, b) => a + b);
  List<int> pool = _generatePool(sum, random, input);

  for (int attempt = 0; attempt < 100; attempt++) {
    pool.shuffle(random);

    // Build initial array by distributing pool
    List<List<int>> array = _buildInitialArray(input, pool);

    // Fix violations through swapping
    if (_fixViolations(array, random, maxIterations: 10000)) {
      return array;
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
}) {
  int iterations = 0;

  while (iterations < maxIterations) {
    List<Violation> violations = _findViolations(array);

    if (violations.isEmpty) {
      return true;
    }

    iterations++;

    // Pick a random violation to fix
    Violation violation = violations[random.nextInt(violations.length)];

    // Try to fix it with swaps
    if (_tryFixViolation(array, violation, random)) {
      continue; // Fixed, check for more violations
    }

    // If we can't fix this violation, try swapping randomly to escape local minimum
    if (iterations % 100 == 0) {
      _randomSwap(array, random);
    }
  }

  return false; // Failed to fix within iteration limit
}

List<Violation> _findViolations(List<List<int>> array) {
  List<Violation> violations = [];

  for (int row = 0; row < array.length; row++) {
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
  List<int> pool = [];

  // Check if all rows have length 1 (can't use 0)
  bool allOnes = input.every((len) => len == 1);

  // Add complete sets of 10 digits (0-9)
  int completeSets = sum ~/ 10;
  for (int i = 0; i < completeSets; i++) {
    if (allOnes) {
      pool.addAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 1]);
    } else {
      pool.addAll([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    }
  }

  // Add remaining digits from a random partial set
  int remainder = sum % 10;
  if (remainder > 0) {
    List<int> partialSet = allOnes
        ? [1, 2, 3, 4, 5, 6, 7, 8, 9]
        : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    partialSet.shuffle(random);
    pool.addAll(partialSet.take(remainder));
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

enum ViolationType { rowDuplicate, verticalDuplicate, lastColZero }

// Example usage and testing
void main() {
  print('Testing [8, 8, 8, 8, 8, 8, 8, 8, 8, 8]...');
  List<int> input0 = [8, 8, 8, 8, 8, 8, 8, 8, 8, 8];
  print('Input: $input0 (sum: ${input0.fold(0, (a, b) => a + b)})');
  var result0 = generate2DArray(input0);
  _printArray(result0);
  _validateArray(result0, input0);

  print('\n---\n');

  List<int> input1 = [1, 1, 1, 1, 1, 1, 1];
  print('Input: $input1 (sum: ${input1.fold(0, (a, b) => a + b)})');
  var result1 = generate2DArray(input1);
  _printArray(result1);
  _validateArray(result1, input1);

  print('\n---\n');

  List<int> input2 = [5, 6, 7, 8, 5, 6, 7, 8, 8, 7];
  print('Input: $input2 (sum: ${input2.fold(0, (a, b) => a + b)})');
  var result2 = generate2DArray(input2);
  _printArray(result2);
  _validateArray(result2, input2);
}

void _printArray(List<List<int>> arr) {
  for (var row in arr) {
    print(row);
  }
}

void _validateArray(List<List<int>> arr, List<int> input) {
  print('\nValidation:');

  for (int i = 0; i < arr.length; i++) {
    if (arr[i].length != input[i]) {
      print('❌ Row $i has wrong length: ${arr[i].length} != ${input[i]}');
      return;
    }
  }
  print('✓ Row lengths match input');

  for (int i = 0; i < arr.length; i++) {
    if (arr[i].toSet().length != arr[i].length) {
      print('❌ Row $i has duplicates: ${arr[i]}');
      return;
    }
  }
  print('✓ All digits unique within rows');

  for (int i = 1; i < arr.length; i++) {
    for (int j = 0; j < arr[i].length && j < arr[i - 1].length; j++) {
      if (arr[i][j] == arr[i - 1][j]) {
        print('❌ Digit at row $i, col $j matches digit above');
        return;
      }
    }
  }
  print('✓ No digit matches the one immediately above');

  for (int i = 0; i < arr.length; i++) {
    if (arr[i].last == 0) {
      print('❌ Row $i ends with 0: ${arr[i]}');
      return;
    }
  }
  print('✓ No row ends with 0');

  print('\n✅ All constraints satisfied!');
}

