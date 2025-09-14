import 'package:decimal/decimal.dart';
import 'generation_spec.dart';
import 'multiplication_source.dart';
import 'division.dart';

class MultiplicationProblem {
  final Decimal multiplicand;
  final Decimal multiplier;
  final Decimal product;

  MultiplicationProblem._(this.multiplicand, this.multiplier, this.product);

  factory MultiplicationProblem({required MultiplicationSpec spec}) {
    final split = DivisionProblem.splitDigits(
      spec,
      digitSplit: digitSplit,
      firstDigits: 0,
      secondDigits: 0,
    );

    Decimal multiplicand = DivisionProblem.randomDecimal(split.firstDigits);
    Decimal multiplier = DivisionProblem.randomDecimal(split.secondDigits);

    if (!spec.integerMultiplicand) {
      (multiplicand, _) = DivisionProblem.scaleValue(multiplicand);
    }
    if (!spec.integerMultiplier) {
      (multiplier, _) = DivisionProblem.scaleValue(multiplier);
    }

    final product = multiplicand * multiplier;

    return MultiplicationProblem._(multiplicand, multiplier, product);
  }

  String get formattedMultiplicand =>
      DivisionProblem.formatDecimal(multiplicand);
  String get formattedMultiplier => DivisionProblem.formatDecimal(multiplier);
  String get formattedProduct => DivisionProblem.formatDecimal(product);

  @override
  String toString() {
    return 'multiplicand=$formattedMultiplicand, multiplier=$formattedMultiplier product=$formattedProduct';
  }
}

void main() {
  final baseSpec = MultiplicationSpec(
    probCount: 15,
    digitCount: 9,
    difficulty: "1kyuu",
    integerMultiplier: false,
  );

  final problem = MultiplicationProblem(spec: baseSpec);

  print(problem);
}
