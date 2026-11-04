import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import 'divmult_set.dart';

class DivisionProblem extends DivMultProblem {
  final Decimal dividend;
  final Decimal divisor;
  final Decimal quotient;
  final bool intRound;

  DivisionProblem._(this.dividend, this.divisor, this.quotient, this.intRound);

  factory DivisionProblem({required DivMultSpec spec, Random? random}) {
    final rand = random ?? Random();
    final split = spec.split;
    late final totalDigits = spec.digitCount;
    late final int divisorDigits = split[0];
    late final int quotientDigits = split[1];

    switch (spec.problemType) {
      case .type1: //Integer dividend, integer divisor, neat
        return _type1(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type2: //Non-integer dividend, non-integer divisor, neat
        return _type2(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type3: //Non-integer dividend, non-integer divisor, unneat
        return _type3(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type4: //Integer dividend, non-integer divisor, neat
        return _type4(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type5: //Integer dividend, non-integer divisor, unneat
        return _type5(totalDigits, divisorDigits, spec.intRound, rand);
      case .type6: //Non-integer dividend, integer divisor, neat
        return _type6(totalDigits, divisorDigits, spec.intRound, rand);
      case .type7: //Non-integer dividend, integer divisor, unneat
        return _type7(divisorDigits, quotientDigits, spec.intRound, rand);
    }
  }

  String get formattedFirst => formatWithCommas(dividend.toString());
  String get formattedSecond => formatWithCommas(divisor.toString());
  @override
  String get formattedThird => formatWithCommas(quotient.toString());

  @override
  String get problem => intRound
      ? '\\ $formattedFirst / $formattedSecond' // yen symbol
      : '$formattedFirst / $formattedSecond';

  @override
  String toString() {
    return '$formattedFirst / $formattedSecond = $formattedThird';
  }

  static DivisionProblem _type1(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    final divisor = randomDecimal(dDigits, rand);
    final quotient = randomDecimalNoTrailingZero(qDigits, rand);
    final dividend = divisor * quotient;
    return DivisionProblem._(dividend, divisor, quotient, intRound);
  }

  static DivisionProblem _type2(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    final Decimal divisor = randomDecimalNoTrailingZero(dDigits, rand);
    final Decimal quotient = randomDecimalNoTrailingZero(qDigits, rand);

    final (Decimal scaledDivisor, _) = scaleValue(divisor, rand);

    final (Decimal scaledQuotient, _) = scaleValue(
      quotient,
      rand,
      avoidScaleOverThree: true,
    );

    final Decimal dividend = scaledDivisor * scaledQuotient;

    return DivisionProblem._(dividend, scaledDivisor, scaledQuotient, intRound);
  }

  static DivisionProblem _type3(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    final (Decimal scaledDivisor, _) = scaleValue(
      randomDecimalNoTrailingZero(dDigits, rand),
      rand,
    );

    final Decimal scaledQuotient = randomDecimalNoTrailingZero(
      qDigits,
      rand,
    ).shift(-3);

    Decimal dividend = scaledDivisor * scaledQuotient;
    dividend = _makeDivisionUnneat(
      dividend,
      scaledDivisor,
      scaledQuotient,
      rand,
    );

    return DivisionProblem._(dividend, scaledDivisor, scaledQuotient, intRound);
  }

  static DivisionProblem _type4(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    while (true) {
      int digitsBeforeDecimal = rand.nextInt(dDigits - 1);
      int divisorDecimals = dDigits - digitsBeforeDecimal;

      int fixed = divisorDecimals;
      int randomNumber = rand.nextInt(divisorDecimals);

      int a, b;
      if (rand.nextBool()) {
        a = fixed;
        b = randomNumber;
      } else {
        a = randomNumber;
        b = fixed;
      }

      int denominator = buildDenominatorForExactlyK(a: a, b: b);

      int numerator = randomNumeratorForExactlyK(
        denominator,
        divisorDecimals,
        digitsBeforeDecimal,
        rand,
      );

      Decimal divisor =
          (Decimal.fromInt(numerator) / Decimal.fromInt(denominator))
              .toDecimal();
      String divisorDigits = divisor.toString().replaceAll('.', '');
      if (divisorDigits.length != divisorDigits.split('').toSet().length) {
        continue;
      }

      int qInt = randomMultipleForDenominator(denominator, qDigits, rand);

      if (qInt == -1) {
        continue;
      }

      Decimal quotient = Decimal.fromInt(qInt);
      Decimal dividend = divisor * quotient;

      return DivisionProblem._(dividend, divisor, quotient, intRound);
    }
  }

  static DivisionProblem _type5(
    int totalDigits,
    int dDigits,
    bool intRound,
    Random rand,
  ) {
    final (Decimal divisor, int divisorScale) = scaleValue(
      randomDecimalNoTrailingZero(dDigits, rand),
      rand,
    );

    Decimal dividend = randomDecimal(totalDigits - divisorScale, rand);
    Decimal quotient = (dividend / divisor).round().toDecimal();
    RegExp sigFigRegEx = RegExp(r'^0+|\.');

    final sigFigsDivisor = divisor
        .toString()
        .replaceAll(sigFigRegEx, '')
        .length;
    final sigFigsQuotient = quotient
        .toString()
        .replaceAll(sigFigRegEx, '')
        .length;
    final totalSigFigs = sigFigsDivisor + sigFigsQuotient;

    Decimal newDividend = dividend;

    if (totalSigFigs != totalDigits) {
      final diff = totalDigits - totalSigFigs;
      newDividend = dividend.shift(diff).floor();
    }

    quotient = (newDividend / divisor).round().toDecimal();
    return DivisionProblem._(newDividend, divisor, quotient, intRound);
  }

  static DivisionProblem _type6(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    final Decimal divisor = randomDecimal(dDigits, rand);
    Decimal quotient = randomDecimalNoTrailingZero(qDigits, rand);
    (quotient, _) = scaleValue(quotient, rand);
    final dividend = divisor * quotient;
    return DivisionProblem._(dividend, divisor, quotient, intRound);
  }

  static DivisionProblem _type7(
    int dDigits,
    int qDigits,
    bool intRound,
    Random rand,
  ) {
    final Decimal divisor = randomDecimal(dDigits, rand);

    final Decimal scaledQuotient = randomDecimalNoTrailingZero(
      qDigits,
      rand,
    ).shift(-3);

    Decimal dividend = divisor * scaledQuotient;
    dividend = _makeDivisionUnneat(dividend, divisor, scaledQuotient, rand);

    return DivisionProblem._(dividend, divisor, scaledQuotient, intRound);
  }

  static Decimal _makeDivisionUnneat(
    Decimal originalDividend,
    Decimal divisor,
    Decimal quotient,
    Random rand,
  ) {
    // Calculate the range of quotient values that round to the given quotient
    Decimal pointFive = (Decimal.fromInt(5) / Decimal.fromInt(10000))
        .toDecimal();
    Decimal lowerQuotientBound = quotient - pointFive;
    Decimal upperQuotientBound = quotient + pointFive;

    // Convert quotient bounds to dividend bounds
    Decimal lowerDividendBound = lowerQuotientBound * divisor;
    Decimal upperDividendBound = upperQuotientBound * divisor;

    // Get the scale (number of decimal places) of the original dividend
    String dividendStr = originalDividend.toString();
    int decimalPlaces = 0;
    if (dividendStr.contains('.')) {
      decimalPlaces = dividendStr.split('.')[1].length;
    }

    // Calculate the maximum allowed perturbation
    Decimal distanceToLower = originalDividend - lowerDividendBound;
    Decimal distanceToUpper = upperDividendBound - originalDividend;
    Decimal maxPerturbation = (distanceToLower < distanceToUpper)
        ? distanceToLower
        : distanceToUpper;

    // Ensure we have a minimum perturbation
    Decimal minPerturbation = (Decimal.one / Decimal.fromInt(100000000))
        .toDecimal(); // 1e-8

    if (maxPerturbation < minPerturbation) {
      maxPerturbation = minPerturbation;
    }

    // Generate a random perturbation amount
    double minPerturbationDouble = double.parse(minPerturbation.toString());
    double maxPerturbationDouble = double.parse(maxPerturbation.toString());
    double perturbationDouble =
        minPerturbationDouble +
        rand.nextDouble() * (maxPerturbationDouble - minPerturbationDouble);

    Decimal perturbation = Decimal.parse(
      perturbationDouble.toStringAsFixed(10),
    );

    // Randomly choose to add or subtract the perturbation
    bool shouldAdd = rand.nextBool();
    Decimal newDividend;

    if (shouldAdd) {
      newDividend = originalDividend + perturbation;
      if (newDividend >= upperDividendBound) {
        newDividend = originalDividend - perturbation;
      }
    } else {
      newDividend = originalDividend - perturbation;
      if (newDividend < lowerDividendBound) {
        newDividend = originalDividend + perturbation;
      }
    }

    // Format the new dividend to have the same number of decimal places
    String newDividendStr = newDividend.toString();
    if (newDividendStr.contains('.')) {
      List<String> parts = newDividendStr.split('.');
      if (parts[1].length > decimalPlaces) {
        // Round to the original number of decimal places
        Decimal factor = (Decimal.fromInt(10).pow(decimalPlaces)).toDecimal();
        newDividend = (((newDividend * factor).round() / factor)).toDecimal();
      } else if (parts[1].length < decimalPlaces) {
        // Pad with zeros
        newDividendStr =
            '${parts[0]}.${parts[1]}${'0' * (decimalPlaces - parts[1].length)}';
        newDividend = Decimal.parse(newDividendStr);
      }
    }

    return newDividend;
  }

  static int _gcd(int a, int b) {
    // Find greatest common denominator
    while (b != 0) {
      int t = a % b;
      a = b;
      b = t;
    }
    return a.abs();
  }

  static Map<String, int> _stripFactor(int n, int p) {
    int e = 0;
    while (n % p == 0 && n != 0) {
      n ~/= p;
      e++;
    }
    return {'exp': e, 'rem': n};
  }

  static Map<String, int> reducedDenominatorExponents(int den) {
    var two = _stripFactor(den, 2);
    var five = _stripFactor(two['rem']!, 5);

    return {'a': two['exp']!, 'b': five['exp']!, 'rem': five['rem']!};
  }

  static int randomNumeratorForExactlyK(
    int den,
    int k,
    int digitsBeforeDecimal,
    Random rand,
  ) {
    int minNum = den * pow(10, digitsBeforeDecimal - 1).toInt();
    int maxNum = den * pow(10, digitsBeforeDecimal).toInt() - 1;

    int candidate() {
      int r = minNum + rand.nextInt(maxNum - minNum + 1);
      while (_gcd(r, 10) != 1) {
        r = minNum + rand.nextInt(maxNum - minNum + 1);
      }
      return r;
    }

    return candidate();
  }

  static int randomMultipleForDenominator(int den, int qDigits, Random rand) {
    int minK = (pow(10, qDigits - 1) / den).ceil();
    int maxK = (pow(10, qDigits) / den).floor() - 1;
    if (maxK < minK) return -1;

    List<int> candidates = [];
    for (int k = minK; k <= maxK; k++) {
      int multiple = den * k;
      String s = multiple.toString();
      if (s.length == s.split('').toSet().length) {
        candidates.add(multiple);
      }
    }

    if (candidates.isEmpty) return -1;
    return candidates[rand.nextInt(candidates.length)];
  }

  static int buildDenominatorForExactlyK({int a = 0, int b = 0}) {
    return pow(2, a).toInt() * pow(5, b).toInt();
  }
}
