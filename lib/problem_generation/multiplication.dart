import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import 'generation_spec.dart';
import 'multiplication_source.dart';

class MultiplicationProblem {
  final Decimal multiplicand;
  final Decimal multiplier;
  final Decimal product;

  MultiplicationProblem._(this.multiplicand, this.multiplier, this.product);

  factory MultiplicationProblem({required MultiplicationSpec spec}) {
    final split = splitDigits(
      spec,
      digitSplit: digitSplit,
      firstDigits: 0,
      secondDigits: 0,
    );

    Decimal multiplicand;
    Decimal multiplier;

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
}

void main() {
  final baseSpec = MultiplicationSpec(
    digitCount: 9,
    difficulty: "1kyuu",
    integerMultiplier: false,
  );

  final multiplicationSet =
      ProblemSet<MultiplicationProblem, MultiplicationSpec>(
        builder: (spec, type) =>
            MultiplicationProblem(spec: multSpecFromType(spec, type)),
        source: multiplicationSource,
      );

  final problems = multiplicationSet.generateProblems(base: baseSpec);

  for (var i = 0; i < problems.length; i++) {
    print("Problem ${i + 1}: ${problems[i]}");
  }
}
