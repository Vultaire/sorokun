import 'dart:math';

import 'generation_spec.dart';
import 'abacus.dart';
import 'dart:convert';
import 'dart:io';

const int generateRetryLimit = 100;
late Map<String, dynamic> difficultyThresholds;

// ---------------------------------
// Helpers
// ---------------------------------

int getRandomDigit(Random rand, {List<int> excepts = const []}) {
  final available = <int>[];
  for (int i = 0; i < 10; i++) {
    if (!excepts.contains(i)) {
      available.add(i);
    }
  }
  return available[rand.nextInt(available.length)];
}

int getRandomInt(
  int digitCount,
  List<int> allPreviousNums,
  int? previousNum,
  GenerationSpec options,
) {
  final rand = Random();
  final previousNumDigits = previousNum == null
      ? <int>[]
      : previousNum.abs().toString().split('').map(int.parse).toList();

  while (true) {
    // First digit (avoid leading 0, and avoid previousNum last digit if provided)
    List<int> firstExcepts = [0];
    if (previousNumDigits.isNotEmpty) {
      firstExcepts.add(previousNumDigits.first);
    }
    int firstDigit = getRandomDigit(rand, excepts: firstExcepts);

    final digits = <int>[firstDigit];

    // Remaining digits
    for (int i = 1; i < digitCount; i++) {
      List<int> excepts = [];
      if (previousNumDigits.length > i) {
        excepts.add(previousNumDigits[i]);
      }
      if (options.digitAllDifferent!) {
        excepts.addAll(digits);
      }
      int nextDigit = getRandomDigit(rand, excepts: excepts);
      digits.add(nextDigit);
    }

    int number = int.parse(digits.join());

    if (options.allowMinus! && rand.nextDouble() < 0.3) {
      if (options.neverNegative! &&
          number > allPreviousNums.fold(0, (a, b) => a + b)) {
        continue;
      }
      number = -number;
    }
    return number;
  }
}

double calculateComplexity(List<int> carries, int digit) {
  List<double> normalized = carries.map((c) => c / digit).toList();

  double avg = normalized.reduce((a, b) => a + b) / (normalized.length - 1);

  double stddev = 0.0;
  if (normalized.length > 1) {
    double mean = avg;
    double variance =
        normalized
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b)
            .toDouble() /
        (normalized.length - 1);
    stddev = sqrt(variance);
  }
  print(normalized);
  print(avg);
  print(carries);

  return avg + 0.25 * stddev;
}

// ---------------------------------
// Flash Addition Generator
// ---------------------------------

class AdditionGenerator {
  final int digitCount;
  final String difficulty;
  GenerationSpec options;
  final List<int> numbers = [];
  final List<int> carries = [];
  final Abacus abacus = Abacus(0);

  AdditionGenerator(this.digitCount, this.difficulty, this.options);

  void addNumber() {
    int? lastNum = numbers.isNotEmpty ? numbers.last : null;

    if (difficulty == "easy") {
      int? bestCandidate;
      int bestCarry = 1 << 30; // big number

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(digitCount, numbers, lastNum, options);
        Abacus tempAbacus = Abacus(abacus.value);
        tempAbacus.add(candidate);
        int carry = tempAbacus.carry;

        if (carry < bestCarry) {
          bestCandidate = candidate;
          bestCarry = carry;
        }

        if (carry == 0) {
          _register(candidate, carry);
          return;
        }
      }

      if (bestCandidate != null) {
        _register(bestCandidate, bestCarry);
      }
    } else if (difficulty == "normal" || difficulty == "random") {
      int candidate = getRandomInt(digitCount, numbers, lastNum, options);
      Abacus tempAbacus = Abacus(abacus.value);
      tempAbacus.add(candidate);
      int carry = tempAbacus.carry;
      _register(candidate, carry);
    } else if (difficulty == "hard") {
      int? bestCandidate;
      int bestCarry = -1;

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(digitCount, numbers, lastNum, options);
        Abacus tempAbacus = Abacus(abacus.value);
        tempAbacus.add(candidate);
        int carry = tempAbacus.carry;

        if (carry > bestCarry) {
          bestCandidate = candidate;
          bestCarry = carry;
        }

        if (carry > 0) {
          _register(candidate, carry);
          return;
        }
      }

      if (bestCandidate != null) {
        _register(bestCandidate, bestCarry);
      }
    }
  }

  void _register(int number, int carry) {
    numbers.add(number);
    carries.add(carry);
    abacus.add(number);
  }
}

// ---------------------------------
// Pick Problem
// ---------------------------------

List<int> pickFlashProblem(
  int digitCount,
  int length,
  String difficulty,
  GenerationSpec options,
) {
  int retry = 0;
  while (retry < generateRetryLimit) {
    var gen = AdditionGenerator(digitCount, difficulty, options);
    for (int i = 0; i < length; i++) {
      gen.addNumber();
    }

    var carries = gen.carries;
    double complexity = calculateComplexity(carries, digitCount);

    // Construct key as string
    String key = '$digitCount-$length';

    // Access thresholds from loaded JSON
    var thresholds = difficultyThresholds['addition']?[key];

    if (thresholds == null) {
      return gen.numbers; // no thresholds available, accept anything
    }

    if (difficulty == "random") {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (difficulty == "easy" && complexity <= thresholds['easy']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (difficulty == "normal" &&
        complexity >= thresholds['easy']! &&
        complexity < thresholds['hard']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (difficulty == "hard" && complexity >= thresholds['hard']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    }

    retry++;
  }

  throw Exception("Retry limit exceeded");
}

// ---------------------------------
// Main
// ---------------------------------

Future<void> main() async {
  // Load JSON thresholds into global
  final file = File('assets/complexityThresholdMap.json');
  final jsonString = await file.readAsString();
  difficultyThresholds = jsonDecode(jsonString);

  // Example usage
  int digitCount = 3;
  int length = 15;
  String difficulty = "random";

  var flashOptions = GenerationSpec(
    allowMinus: true,
    digitAllDifferent: true,
    neverNegative: true,
  );

  var problem = pickFlashProblem(digitCount, length, difficulty, flashOptions);
  print("Problem: $problem");
  print("Sum: ${problem.reduce((a, b) => a + b)}");
}
