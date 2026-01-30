import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import '../models/level_definitions.dart';
import 'divmult_set.dart';

class MultiplicationProblem {
  final Decimal multiplicand;
  final Decimal multiplier;
  final Decimal product;

  MultiplicationProblem._(this.multiplicand, this.multiplier, this.product);

  factory MultiplicationProblem({required DivMultSpec spec}) {
    final split = splitDigits(split: spec.split, rand: Random());
    late final int multiplicandDigits = split.firstDigits;
    late final int multiplierDigits = split.secondDigits;

    switch (spec.problemType) {
      case .type1: //Integer multiplicand, integer multiplier
        return _type1(multiplicandDigits, multiplierDigits);
      case .type2: //Non-integer multiplicand, non-integer multiplier
        return _type2(multiplicandDigits, multiplierDigits);
      case .type3:
        throw ArgumentError(
          'ProblemType.type3 is not valid for multiplication specs',
        );
      case .type4: //Integer multiplicand, non-integer multiplier, may swap
        return _type4(multiplicandDigits, multiplierDigits);
      case .type5: //Integer multiplicand, non-integer multiplier, may not swap
        return _type5(multiplicandDigits, multiplierDigits);
    }
  }

  String get formattedFirst => formatWithCommas(multiplicand.toString());
  String get formattedSecond => formatWithCommas(multiplier.toString());
  String get formattedThird => formatWithCommas(product.toString());

  String get problem => '$formattedFirst * $formattedSecond';
  String get problemWithYenSymbol => '\\ $formattedFirst * $formattedSecond';

  @override
  String toString() {
    return '$formattedFirst * $formattedSecond = $formattedThird';
  }

  static MultiplicationProblem _type1(
    int multiplicandDigits,
    int multiplierDigits,
  ) {
    final Decimal multiplicand = randomDecimal(multiplicandDigits);
    final Decimal multiplier = randomDecimal(multiplierDigits);
    final Decimal product = multiplicand * multiplier;

    return MultiplicationProblem._(multiplicand, multiplier, product);
  }

  static MultiplicationProblem _type2(
    int multiplicandDigits,
    int multiplierDigits,
  ) {
    Decimal multiplicand = randomDecimalNoTrailingZero(multiplicandDigits);
    (multiplicand, _) = scaleValue(multiplicand);
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits);
    (multiplier, _) = scaleValue(multiplier);

    Decimal product = multiplicand * multiplier;
    product = Decimal.parse(product.toStringAsFixed(3));

    return MultiplicationProblem._(multiplicand, multiplier, product);
  }

  static MultiplicationProblem _type4(
    int multiplicandDigits,
    int multiplierDigits,
  ) {
    Decimal multiplicand = randomDecimal(multiplicandDigits);
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits);
    (multiplier, _) = scaleValue(multiplier);
    final rand = Random();

    if (rand.nextBool()) {
      [multiplicand, multiplier] = [multiplier, multiplicand];
    }

    Decimal product = multiplicand * multiplier;
    product = Decimal.parse(product.toStringAsFixed(3));

    return MultiplicationProblem._(multiplicand, multiplier, product);
  }

  static MultiplicationProblem _type5(
    int multiplicandDigits,
    int multiplierDigits,
  ) {
    Decimal multiplicand = randomDecimal(multiplicandDigits);
    Decimal multiplier = randomDecimalNoTrailingZero(multiplierDigits);
    (multiplier, _) = scaleValue(multiplier);

    Decimal product = multiplicand * multiplier;
    product = Decimal.parse(product.toStringAsFixed(0));

    return MultiplicationProblem._(multiplicand, multiplier, product);
  }
}

void main() {
  final problems = DivMultProblemSet(level: DivMultLevel.mk2);

  print(problems.formattedProblems);
  print(problems.formattedAnswers);

  // for (var i = 0; i < problems.length; i++) {
  //   print("Problem ${i + 1}: ${problems[i]}");
  // }
}
