import 'dart:math';
import 'abacus.dart';
import 'dart:convert';
import 'dart:io';

const int generateRetryLimit = 100;
late Map<String, dynamic> difficultyThresholds;

// ---------------------------------
// Helpers
// ---------------------------------

int getRandomInt(int digitCount, {int? exceptLastDigit}) {
  final rand = Random();
  while (true) {
    int minVal = pow(10, digitCount - 1).toInt();
    int maxVal = pow(10, digitCount).toInt() - 1;
    int number = minVal + rand.nextInt(maxVal - minVal + 1);

    if (exceptLastDigit != null) {
      if (number % 10 != exceptLastDigit) {
        return number;
      }
    } else {
      return number;
    }
  }
}

double calculateComplexity(List<int> carries, int digit) {
  List<double> normalized = carries.map((c) => c / digit).toList();

  double avg = normalized.reduce((a, b) => a + b) / normalized.length;

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
  print(carries);

  return avg + 0.25 * stddev;
}

// ---------------------------------
// Flash Addition Generator
// ---------------------------------

class AdditionGenerator {
  final int digitCount;
  final String difficulty;
  final List<int> numbers = [];
  final List<int> carries = [];
  final Abacus abacus = Abacus(0);

  AdditionGenerator(this.digitCount, this.difficulty);

  void addNumber() {
    int? lastNum = numbers.isNotEmpty ? numbers.last : null;
    int? lastDigit = lastNum != null ? lastNum % 10 : null;

    if (difficulty == "easy") {
      int? bestCandidate;
      int bestCarry = 1 << 30; // big number

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(digitCount, exceptLastDigit: lastDigit);
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
      int candidate = getRandomInt(digitCount, exceptLastDigit: lastDigit);
      Abacus tempAbacus = Abacus(abacus.value);
      tempAbacus.add(candidate);
      int carry = tempAbacus.carry;
      _register(candidate, carry);
    } else if (difficulty == "hard") {
      int? bestCandidate;
      int bestCarry = -1;

      for (int i = 0; i < 20; i++) {
        int candidate = getRandomInt(digitCount, exceptLastDigit: lastDigit);
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

List<int> pickFlashProblem(int digitCount, int length, String difficulty) {
  int retry = 0;
  while (retry < generateRetryLimit) {
    var gen = AdditionGenerator(digitCount, difficulty);
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
  int digitCount = 2;
  int length = 15;
  String difficulty = "random";

  var problem = pickFlashProblem(digitCount, length, difficulty);
  print("Problem: $problem");
  print("Sum: ${problem.reduce((a, b) => a + b)}");

  String key = '$digitCount-$length';
  var thresholds = difficultyThresholds['addition']?[key];
  print('Thresholds: $thresholds');
}
