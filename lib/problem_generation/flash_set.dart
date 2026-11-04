import 'dart:math';

import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/mitori.dart';

import 'abacus.dart';

class FlashProblemSet {
  final FlashSpec spec;
  final List<MitoriProblem> mitoriProblemList;

  FlashProblemSet(this.spec, {Random? random})
    : mitoriProblemList = List.generate(
        spec.probCount,
        (_) => MitoriProblem(spec.builder(spec, random ?? Random())),
      );

  List<List<String>> get formattedProblems =>
      mitoriProblemList.map((i) => i.formattedProblem).toList();
  List<String> get formattedAnswers =>
      mitoriProblemList.map((i) => i.formattedAnswer).toList();
}

List<int> zsk19Builder(FlashLevel level, Random rand) {
  return [5, rand.nextInt(4) + 1];
}

List<int> zsk7Builder(FlashLevel level, Random rand) {
  List<int> randomDigits = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  randomDigits.shuffle(rand);
  final List<int> picked = randomDigits.take(4).toList();
  List<int> numbers = [
    picked[0] * 10,
    picked[1] * 10,
    (picked[2] * 10 + picked[3]),
  ];
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
      if (i != -numbers.last && i != 0 && i != numbers.last) {
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
