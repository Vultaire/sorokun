import 'dart:math';

import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/problem_generation/mitori.dart';

import 'helpers.dart';
import 'abacus.dart';

// ---------------------------------
// Helpers
// ---------------------------------

class FlashProblemSet {
  final FlashSpec spec;
  List<List<String>> formattedProblems = [];
  List<String> formattedAnswers = [];

  FlashProblemSet(this.spec) {
    late final List<List<int>> problems = List.generate(
      spec.probCount,
      (_) => spec.builder(spec, Random()),
    );

    List<int> answers = problems
        .map((problem) => problem.reduce((a, b) => a + b))
        .toList();

    formattedProblems = problems
        .map(
          (problem) => problem
              .map((number) => formatWithCommas(number.toString()))
              .toList(),
        )
        .toList();

    formattedAnswers = answers
        .map((sum) => formatWithCommas(sum.toString()))
        .toList();
  }
}

List<int> zsk19Builder(FlashLevel level, Random rand) {
  return [5, rand.nextInt(4) + 1];
}

List<int> zsk7Builder(FlashLevel level, Random rand) {
  List<int> randomDigits = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  randomDigits.shuffle(rand);
  final List<int> picked = randomDigits.take(4).toList();
  List<int> numbers = [picked[0] * 10, picked[1] * 10];
  numbers.shuffle(rand);
  return numbers;
}

List<int> kkk19Builder(FlashLevel level, Random rand) {
  return [5, rand.nextInt(4) + 1, -5];
}

List<int> noCarry(FlashLevel level, Random rand) {
  List<int> numbers = [];
  int absoluteRange = level.constrainUnder4
      ? 4
      : 9; //kyoukai 20kyuu restricts numbers to under 4

  numbers.add(rand.nextInt(absoluteRange) + 1);
  Abacus abacus = Abacus(numbers.last);

  while (numbers.length < level.kuchi) {
    final candidates = <int>[];
    for (int i = -absoluteRange; i <= absoluteRange; i++) {
      if (!numbers.contains(i) && i != 0 && !numbers.contains(-i)) {
        candidates.add(i);
      }
    }

    final validNumbers = candidates.where((candidate) {
      Abacus temp = Abacus(abacus.value);
      temp.add(candidate);
      if (level.someCarriesAllowed) {
        return temp.carry < 2 && temp.value >= 0;
      } else {
        return temp.carry == 0 && temp.value >= 0;
      }
    }).toList();

    final candidate = validNumbers[rand.nextInt(validNumbers.length)];
    abacus.add(candidate);
    numbers.add(candidate);
  }
  return numbers;
}

List<int> mitoriStyle(FlashSpec level, Random rand) {
  final List<int> digitList = List.filled(level.kuchi, level.digits);
  final List<int> numbers = generateMitoriProblemFromDigitList(digitList, rand);
  return numbers;
}

List<int> multiplierBuilder(FlashLevel level, Random rand) {
  List<int> singleDigits = noCarry(level, rand);
  final List<int> numbers = singleDigits
      .map((number) => number * level.multiplier)
      .toList();

  return numbers;
}

// List<int> noCarryList(
//   int? previousNum,
//   List<int> allPreviousNums,
//   FlashSpec spec,
// ) {
//   final noCarries = <int>[];
//   if (spec.allowMinus) {
//     for (int i = -9; i < 10; i++) {
//       if (i != previousNum && i != 0) {
//         noCarries.add(i);
//       }
//     }
//   } else {
//     for (int i = 1; i < 10; i++) {
//       if (i != previousNum) {
//         noCarries.add(i);
//       }
//     }
//   }
//   return noCarries;
// }
//
// double calculateComplexity(List<int> carries, int digit) {
//   List<double> normalized = carries.map((c) => c / digit).toList();
//
//   double avg = normalized.reduce((a, b) => a + b) / (normalized.length - 1);
//
//   double stddev = 0.0;
//   if (normalized.length > 1) {
//     double mean = avg;
//     double variance =
//         normalized
//             .map((x) => pow(x - mean, 2))
//             .reduce((a, b) => a + b)
//             .toDouble() /
//         (normalized.length - 1);
//     stddev = sqrt(variance);
//   }
//   print(normalized);
//   print(avg);
//   print(carries);
//
//   return avg + 0.25 * stddev;
// }
//
// // ---------------------------------
// // Flash Addition Generator
// // ---------------------------------
//
// class FlashGenerator {
//   FlashSpec spec;
//   final List<int> numbers = [];
//   final List<int> carries = [];
//   final Abacus abacus = Abacus(0);
//
//   FlashGenerator(this.spec);
//
//   void addNumber() {
//     int? lastNum = numbers.isNotEmpty ? numbers.last : null;
//
//     if (spec.difficulty == "easy") {
//       int? bestCandidate;
//       int bestCarry = 1 << 30; // big number
//
//       for (int i = 0; i < 20; i++) {
//         int candidate = getRandomFlashInt(
//           spec.digitCount,
//           numbers,
//           lastNum,
//           spec,
//         );
//         Abacus tempAbacus = Abacus(abacus.value);
//         tempAbacus.add(candidate);
//         int carry = tempAbacus.carry;
//
//         if (carry < bestCarry) {
//           bestCandidate = candidate;
//           bestCarry = carry;
//         }
//
//         if (carry == 0) {
//           _register(candidate, carry);
//           return;
//         }
//       }
//
//       if (bestCandidate != null) {
//         _register(bestCandidate, bestCarry);
//       }
//     } else if (spec.difficulty == "normal" || spec.difficulty == "random") {
//       int candidate = getRandomFlashInt(
//         spec.digitCount,
//         numbers,
//         lastNum,
//         spec,
//       );
//       Abacus tempAbacus = Abacus(abacus.value);
//       tempAbacus.add(candidate);
//       int carry = tempAbacus.carry;
//       _register(candidate, carry);
//     } else if (spec.difficulty == "hard") {
//       int? bestCandidate;
//       int bestCarry = -1;
//
//       for (int i = 0; i < 20; i++) {
//         int candidate = getRandomFlashInt(
//           spec.digitCount,
//           numbers,
//           lastNum,
//           spec,
//         );
//         Abacus tempAbacus = Abacus(abacus.value);
//         tempAbacus.add(candidate);
//         int carry = tempAbacus.carry;
//
//         if (carry > bestCarry) {
//           bestCandidate = candidate;
//           bestCarry = carry;
//         }
//
//         if (carry > 0) {
//           _register(candidate, carry);
//           return;
//         }
//       }
//
//       if (bestCandidate != null) {
//         _register(bestCandidate, bestCarry);
//       }
//     } else if (spec.difficulty == "noCarry") {
//       //Should only be used for 20-11kyuu
//       List<int> candidates = noCarryList(lastNum, numbers, spec);
//
//       final validNumbers = candidates.where((candidate) {
//         Abacus temp = Abacus(abacus.value);
//         temp.add(candidate);
//         return temp.carry == 0;
//       }).toList();
//
//       final candidate = validNumbers[Random().nextInt(validNumbers.length)];
//
//       _register(candidate, 0);
//     }
//   }
//
//   void _register(int number, int carry) {
//     numbers.add(number);
//     carries.add(carry);
//     abacus.add(number);
//   }
// }
//
// // ---------------------------------
// // Pick Problem
// // ---------------------------------
//
// List<int> pickFlashProblem(FlashSpec spec) {
//   int retry = 0;
//   while (retry < generateRetryLimit) {
//     var gen = FlashGenerator(spec);
//     for (int i = 0; i < spec.length; i++) {
//       gen.addNumber();
//     }
//
//     var carries = gen.carries;
//     double complexity = calculateComplexity(carries, spec.digitCount);
//
//     String key = '${spec.digitCount}-${spec.length}';
//
//     var thresholds = difficultyThresholds['addition']?[key];
//
//     if (thresholds == null) {
//       return gen.numbers; // no thresholds available, accept anything
//     }
//
//     if (spec.difficulty == "random") {
//       print(
//         "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
//       );
//       return gen.numbers;
//     } else if (spec.difficulty == "easy" && complexity <= thresholds['easy']!) {
//       print(
//         "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
//       );
//       return gen.numbers;
//     } else if (spec.difficulty == "normal" &&
//         complexity >= thresholds['easy']! &&
//         complexity < thresholds['hard']!) {
//       print(
//         "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
//       );
//       return gen.numbers;
//     } else if (spec.difficulty == "hard" && complexity >= thresholds['hard']!) {
//       print(
//         "complexity=${complexity.toStringAsFixed(3)}, thresholds=$thresholds",
//       );
//       return gen.numbers;
//     } else if (spec.difficulty == "noCarry") {
//       print("complexity=${complexity.toStringAsFixed(3)}, carry=$carries");
//       return gen.numbers;
//     }
//     retry++;
//   }
//
//   throw Exception("Retry limit exceeded");
// }

Future<void> main() async {
  // Example usage

  var problems = FlashProblemSet(FlashLevel.zsk10);
  print(problems.formattedProblems);
  print(problems.formattedAnswers);
}
