import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import '../models/difficulty.dart';
import 'generation_spec.dart';

class MultiplicationProblem {
  final Decimal multiplicand;
  final Decimal multiplier;
  final Decimal product;

  MultiplicationProblem._(this.multiplicand, this.multiplier, this.product);

  factory MultiplicationProblem({required DivMultSpec spec}) {
    final split = splitDigits(split: spec.split);
    late final int multiplicandDigits = split.firstDigits;
    late final int multiplierDigits = split.secondDigits;

    switch (spec.problemType) {
      case .type1:
        return _type1(multiplicandDigits, multiplierDigits);
      case .type2:
        return _type2(multiplicandDigits, multiplierDigits);
      case .type3:
        throw ArgumentError(
          'ProblemType.type3 is not valid for multiplication specs',
        );
      case .type4:
        return _type4(multiplicandDigits, multiplierDigits);
      case .type5:
        return _type5(multiplicandDigits, multiplierDigits);
    }
    /*
    if (!spec.integerMultiplicand) {
      multiplicand = randomDecimalNoTrailingZero(split.firstDigits);
      (multiplicand, _) = scaleValue(multiplicand);
    } else {
      multiplicand = randomDecimal(split.firstDigits);
    }

    if (!spec.integerMultiplier) {
      multiplier = randomDecimalNoTrailingZero(split.secondDigits);
      (multiplier, _) = scaleValue(multiplier);
    } else {
      multiplier = randomDecimal(split.secondDigits);
    }

    if (spec.maySwap) {
      final rand = Random();
      if (rand.nextBool()) {
        [multiplicand, multiplier] = [multiplier, multiplicand];
      }
    }

    Decimal product = multiplicand * multiplier;

    // Rounding logic
    if (spec.integerMultiplicand == spec.integerMultiplier) {
      product = Decimal.parse(product.toStringAsFixed(3));
    } else {
      product = Decimal.parse(product.toStringAsFixed(0));
    }

    return MultiplicationProblem._(multiplicand, multiplier, product);
*/
  }

  String get formattedFirst => formatWithCommas(multiplicand.toString());
  String get formattedSecond => formatWithCommas(multiplier.toString());
  String get formattedThird => formatWithCommas(product.toString());

  String get first => (multiplicand).toString();
  String get second => (multiplier).toString();
  String get third => (product).toString();

  @override
  String toString() {
    return 'multiplicand=$formattedFirst, multiplier=$formattedSecond product=$formattedThird';
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
  final problems = problemSet(difficulty: Difficulty.mdan);

  for (var i = 0; i < problems.length; i++) {
    print("Problem ${i + 1}: ${problems[i]}");
  }
}
