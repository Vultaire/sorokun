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
  FlashSpec spec,
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
      if (spec.digitAllDifferent) {
        excepts.addAll(digits);
      }
      int nextDigit = getRandomDigit(rand, excepts: excepts);
      digits.add(nextDigit);
    }

    int number = int.parse(digits.join());

    if (spec.allowMinus && rand.nextDouble() < 0.3) {
      if (spec.neverNegative &&
          number > allPreviousNums.fold(0, (a, b) => a + b)) {
        continue;
      }
      number = -number;
    }
    return number;
  }
}

List<int> noCarryList(
  int? previousNum,
  List<int> allPreviousNums,
  FlashSpec spec,
) {
  final noCarries = <int>[];
  if (spec.allowMinus) {
    for (int i = -9; i < 10; i++) {
      if (i != previousNum && i != 0) {
        noCarries.add(i);
      }
    }
  } else {
    for (int i = 1; i < 10; i++) {
      if (i != previousNum) {
        noCarries.add(i);
      }
    }
  }
  return noCarries;
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

class FlashGenerator {
  FlashSpec spec;
  final List<int> numbers = [];
  final List<int> carries = [];
  final Abacus abacus = Abacus(0);

  FlashGenerator(this.spec);

  void addNumber() {
    int? lastNum = numbers.isNotEmpty ? numbers.last : null;

    if (spec.difficulty == "easy") {
      int? bestCandidate;
      int bestCarry = 1 << 30; // big number

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(spec.digitCount, numbers, lastNum, spec);
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
    } else if (spec.difficulty == "normal" || spec.difficulty == "random") {
      int candidate = getRandomInt(spec.digitCount, numbers, lastNum, spec);
      Abacus tempAbacus = Abacus(abacus.value);
      tempAbacus.add(candidate);
      int carry = tempAbacus.carry;
      _register(candidate, carry);
    } else if (spec.difficulty == "hard") {
      int? bestCandidate;
      int bestCarry = -1;

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(spec.digitCount, numbers, lastNum, spec);
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
    } else if (spec.difficulty == "noCarry") {
      //Should only be used for 20-11kyuu
      List<int> candidates = noCarryList(lastNum, numbers, spec);

      final validNumbers = candidates.where((candidate) {
        Abacus temp = Abacus(abacus.value);
        temp.add(candidate);
        return temp.carry == 0;
      }).toList();

      final candidate = validNumbers[Random().nextInt(validNumbers.length)];

      _register(candidate, 0);
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

List<int> pickFlashProblem(FlashSpec spec) {
  int retry = 0;
  while (retry < generateRetryLimit) {
    var gen = FlashGenerator(spec);
    for (int i = 0; i < spec.length; i++) {
      gen.addNumber();
    }

    var carries = gen.carries;
    double complexity = calculateComplexity(carries, spec.digitCount);

    String key = '${spec.digitCount}-${spec.length}';

    var thresholds = difficultyThresholds['addition']?[key];

    if (thresholds == null) {
      return gen.numbers; // no thresholds available, accept anything
    }

    if (spec.difficulty == "random") {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (spec.difficulty == "easy" && complexity <= thresholds['easy']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (spec.difficulty == "normal" &&
        complexity >= thresholds['easy']! &&
        complexity < thresholds['hard']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (spec.difficulty == "hard" && complexity >= thresholds['hard']!) {
      print(
        "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
      );
      return gen.numbers;
    } else if (spec.difficulty == "noCarry") {
      print("complexity=${complexity.toStringAsFixed(3)}, carry=$carries");
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

  var problem = pickFlashProblem(
    getFlashSpec(
      "2dan",
      overrides: {"allowMinus": true, "length": 15, "difficulty": "easy"},
    ),
  );
  print("Problem: $problem");
  print("Sum: ${problem.reduce((a, b) => a + b)}");
}
