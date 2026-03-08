import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import '../models/level_definitions.dart';
import 'divmult_set.dart';

class MultiplicationProblem extends DivMultProblem {
  final Decimal multiplicand;
  final Decimal multiplier;
  final Decimal product;
  final bool intRound;

  MultiplicationProblem._(
    this.multiplicand,
    this.multiplier,
    this.product,
    this.intRound,
  );

  factory MultiplicationProblem({required DivMultSpec spec}) {
    final split = spec.split;
    late final int multiplicandDigits = split[0];
    late final int multiplierDigits = split[1];
    final rand = Random();

    switch (spec.problemType) {
      case .type1: //Integer multiplicand, integer multiplier
        return _type1(
          multiplicandDigits,
          multiplierDigits,
          spec.intRound,
          rand,
        );
      case .type2: //Non-integer multiplicand, non-integer multiplier
        return _type2(
          multiplicandDigits,
          multiplierDigits,
          spec.intRound,
          rand,
        );
      case .type3:
        throw ArgumentError(
          'ProblemType.type3 is not valid for multiplication specs',
        );
      case .type4: //Integer multiplicand, non-integer multiplier, may swap
        return _type4(
          multiplicandDigits,
          multiplierDigits,
          spec.intRound,
          rand,
        );
      case .type5: //Integer multiplicand, non-integer multiplier, may not swap
        return _type5(
          multiplicandDigits,
          multiplierDigits,
          spec.intRound,
          rand,
        );
      case .type6:
        throw ArgumentError(
          'ProblemType.type6 is not valid for multiplication specs',
        );
      case .type7:
        throw ArgumentError(
          'ProblemType.type7 is not valid for multiplication specs',
        );
    }
  }

  String get formattedFirst => formatWithCommas(multiplicand.toString());
  String get formattedSecond => formatWithCommas(multiplier.toString());
  @override
  String get formattedThird => formatWithCommas(product.toString());

  @override
  String get problem => intRound
      ? '\\ $formattedFirst * $formattedSecond'
      : '$formattedFirst * $formattedSecond';

  @override
  String toString() {
    return '$formattedFirst * $formattedSecond = $formattedThird';
  }

  static MultiplicationProblem _type1(
    int multiplicandDigits,
    int multiplierDigits,
    bool intRound,
    Random rand,
  ) {
    final Decimal multiplicand = randomDecimal(multiplicandDigits, rand);
    final Decimal multiplier = randomDecimal(multiplierDigits, rand);
    final Decimal product = multiplicand * multiplier;

    return MultiplicationProblem._(multiplicand, multiplier, product, intRound);
  }

  static MultiplicationProblem _type2(
    int multiplicandDigits,
    int multiplierDigits,
    bool intRound,
    Random rand,
  ) {
    final (multiplicand, multiplicandScale) = scaleValue(
      randomDecimalNoTrailingZero(multiplicandDigits, rand),
      rand,
    );
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits, rand);

    (multiplier, _) = scaleValue(
      multiplier,
      rand,
      avoidScaleOverValueDigits: multiplicandScale > multiplicandDigits,
    );

    Decimal product = multiplicand * multiplier;
    product = Decimal.parse(product.toStringAsFixed(3));

    return MultiplicationProblem._(multiplicand, multiplier, product, intRound);
  }

  static MultiplicationProblem _type4(
    int multiplicandDigits,
    int multiplierDigits,
    bool intRound,
    Random rand,
  ) {
    Decimal multiplicand = randomDecimal(multiplicandDigits, rand);
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits, rand);
    (multiplier, _) = scaleValue(multiplier, rand);

    if (rand.nextBool()) {
      [multiplicand, multiplier] = [multiplier, multiplicand];
    }

    Decimal product = multiplicand * multiplier;
    product = Decimal.parse(product.toStringAsFixed(3));

    return MultiplicationProblem._(multiplicand, multiplier, product, intRound);
  }

  static MultiplicationProblem _type5(
    int multiplicandDigits,
    int multiplierDigits,
    bool intRound,
    Random rand,
  ) {
    Decimal multiplicand = randomDecimal(multiplicandDigits, rand);
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits, rand);
    (multiplier, _) = scaleValue(multiplier, rand);

    Decimal product = multiplicand * multiplier;

    product = Decimal.parse(product.toStringAsFixed(intRound ? 0 : 3));

    return MultiplicationProblem._(multiplicand, multiplier, product, intRound);
  }
}

void main() {
  final problems = DivMultProblemSet(level: DivMultLevel.nsmadan);

  print(problems.formattedProblems);
  print(problems.formattedAnswers);

  // for (var i = 0; i < problems.length; i++) {
  //   print("Problem ${i + 1}: ${problems[i]}");
  // }
}
