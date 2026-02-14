import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import '../models/level_definitions.dart';
import 'divmult_set.dart';

class DivisionProblem extends DivMultProblem {
  final Decimal dividend;
  final Decimal divisor;
  final Decimal quotient;
  final bool intRound;

  DivisionProblem._(this.dividend, this.divisor, this.quotient, this.intRound);

  factory DivisionProblem({required DivMultSpec spec}) {
    late final rand = Random();
    final split = spec.split;
    late final totalDigits = spec.digitCount;
    late final int divisorDigits = split[0];
    late final int quotientDigits = split[1];

    switch (spec.problemType) {
      case .type1: //Integer dividend, integer divisor, neat
        return _type1(divisorDigits, quotientDigits, spec.intRound);
      case .type2: //Non-integer dividend, non-integer divisor, neat
        return _type2(divisorDigits, quotientDigits, spec.intRound);
      case .type3: //Non-integer dividend, non-integer divisor, unneat
        return _type3(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type4: //Integer dividend, non-integer divisor, neat
        return _type4(divisorDigits, quotientDigits, spec.intRound, rand);
      case .type5: //Integer dividend, non-integer divisor, unneat
        return _type5(totalDigits, divisorDigits, spec.intRound);
      case .type6: //Non-integer dividend, integer divisor, neat
        return _type6(totalDigits, divisorDigits, spec.intRound);
    }
  }

  static DivisionProblem _type1(int dDigits, int qDigits, bool intRound) {
    final divisor = randomDecimalNoTrailingZero(dDigits);
    final quotient = randomDecimalNoTrailingZero(qDigits);
    final dividend = divisor * quotient;
    return DivisionProblem._(dividend, divisor, quotient, intRound);
  }

  static DivisionProblem _type2(int dDigits, int qDigits, bool intRound) {
    final Decimal divisor = randomDecimalNoTrailingZero(dDigits);
    final Decimal quotient = randomDecimalNoTrailingZero(qDigits);

    final (Decimal scaledDivisor, _) = scaleValue(divisor);

    final (Decimal scaledQuotient, _) = scaleValue(
      quotient,
      avoidOverScale: true,
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
    final Decimal divisor = randomDecimalNoTrailingZero(dDigits);
    final Decimal quotient = randomDecimalNoTrailingZero(qDigits);

    final (Decimal scaledDivisor, int _) = scaleValue(divisor);

    final (Decimal scaledQuotient, int _) = scaleValue(
      quotient,
      alwaysThree: true,
    );

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

      int qInt = randomMultipleForDenominator(denominator, qDigits, rand);

      if (qInt == -1) {
        continue; // retry
      }

      Decimal quotient = Decimal.fromInt(qInt);
      Decimal dividend = divisor * quotient;

      return DivisionProblem._(dividend, divisor, quotient, intRound);
    }
  }

  static DivisionProblem _type5(int totalDigits, int dDigits, bool intRound) {
    final (divisor, divisorScale) = scaleValue(
      randomDecimalNoTrailingZero(dDigits),
    );

    Decimal dividend = randomDecimal(totalDigits - divisorScale);
    Decimal quotient = (dividend / divisor).round().toDecimal();
    RegExp sigFigRegEx = RegExp(r'^0*\.?');

    final sigFigsDivisor = divisor
        .toString()
        .replaceFirst(sigFigRegEx, '')
        .replaceAll('.', '')
        .length;
    final sigFigsQuotient = quotient
        .toString()
        .replaceFirst(sigFigRegEx, '')
        .replaceAll('.', '')
        .length;
    final totalSigFigs = sigFigsDivisor + sigFigsQuotient;

    if (totalSigFigs < totalDigits) {
      final diff = totalDigits - totalSigFigs;
      dividend *= Decimal.fromInt(pow(10, diff).toInt());
      dividend = dividend.round();
    } else if (totalSigFigs > totalDigits) {
      final diff = totalSigFigs - totalDigits;
      dividend = (dividend / Decimal.fromInt(pow(10, diff).toInt()))
          .toDecimal();
      dividend = dividend.round();
    }

    quotient = (dividend / divisor).round().toDecimal();
    return DivisionProblem._(dividend, divisor, quotient, intRound);
  }

  static DivisionProblem _type6(int dDigits, int qDigits, bool intRound) {
    final Decimal divisor = randomDecimalNoTrailingZero(dDigits);
    Decimal quotient = randomDecimalNoTrailingZero(qDigits);
    (quotient, _) = scaleValue(quotient);
    final dividend = divisor * quotient;
    return DivisionProblem._(dividend, divisor, quotient, intRound);
  }

  static _makeDivisionUnneat(
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
    } else if (decimalPlaces > 0) {
      // Add decimal point with zeros
      newDividendStr = '$newDividendStr.${'0' * decimalPlaces}';
      newDividend = Decimal.parse(newDividendStr);
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

    if (maxK < minK) {
      return -1;
    }

    int k = minK + rand.nextInt(maxK - minK + 1);
    return den * k;
  }

  static int buildDenominatorForExactlyK({int a = 0, int b = 0}) {
    return pow(2, a).toInt() * pow(5, b).toInt();
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
}

Map<String, dynamic> getModoshi(
  Decimal dividend,
  Decimal divisor,
  Decimal quotient,
  bool integerDividend,
) {
  List<int> modoshi = [];
  Decimal remainingDividend = dividend;

  String qStr = quotient.toString();
  int decimalIndex = qStr.indexOf('.');
  bool foundFirstNonZero = false;
  if (decimalIndex == -1) {
    decimalIndex = qStr.length;
  }

  for (int i = 0; i < qStr.length; i++) {
    String qCh = qStr[i];

    // Skip leading zeros and decimal point
    if (!foundFirstNonZero && (qCh == '0' || qCh == '.')) continue;

    foundFirstNonZero = true; // first sig fig found

    if (qCh == '.') continue; // Skip integerDivisor after first sig fig

    int qDigit = int.parse(qCh);
    print('q_digit: $qDigit');

    String remStr = remainingDividend.toString();
    print('rem_str: $remStr');

    String divisorStr = divisor.toString();

    String remDigitsStr = remStr
        .replaceFirst(RegExp(r'^0*\.?0*'), '')
        .replaceAll('.', '');
    String divisorDigitsStr = divisorStr
        .replaceFirst(RegExp(r'^0*\.?0*'), '')
        .replaceAll('.', '');

    if (remDigitsStr.isEmpty) {
      remDigitsStr = remStr;
    }

    int dividendDigit = int.parse(remDigitsStr[0]);
    int divisorDigit = int.parse(divisorDigitsStr[0]);

    String remDigits = remDigitsStr
        .replaceAll('.', '')
        .replaceFirst(RegExp(r'^0+'), '');

    int hypothesis = 0;

    if (qDigit == 0) {
      hypothesis = 0;
    } else if (divisorDigit > dividendDigit) {
      // Compare first two dividend digits if possible
      int firstTwoDividend = remDigits.length >= 2
          ? int.parse(remDigits.substring(0, 2))
          : dividendDigit * 10;
      hypothesis = firstTwoDividend ~/ divisorDigit;
    } else if (divisorDigit == dividendDigit) {
      int n = 2;
      while (n <= divisorDigitsStr.length && n <= remDigits.length) {
        int divPrefix = int.parse(divisorDigitsStr.substring(0, n));
        int remPrefix = int.parse(remDigits.substring(0, n));

        if (remPrefix > divPrefix) {
          hypothesis = 1;
          break;
        } else if (remPrefix < divPrefix) {
          hypothesis = 9;
          break;
        }
        n++;
      }
      if (n > divisorDigitsStr.length || n > remDigits.length) {
        hypothesis = 1;
      }
    } else {
      // first divisor digit smaller
      hypothesis = dividendDigit ~/ divisorDigit;
    }

    print('hypothesis: $hypothesis');

    modoshi.add(qDigit - hypothesis);

    // find the quotient digit's place value to subtract the first quotient place from the dividend
    Decimal scale;
    if (i < decimalIndex) {
      scale = Decimal.fromInt(
        10,
      ).pow(decimalIndex - i - 1).toDecimal(scaleOnInfinitePrecision: 50);
    } else {
      scale = Decimal.fromInt(
        10,
      ).pow(-(i - decimalIndex)).toDecimal(scaleOnInfinitePrecision: 50);
    }
    Decimal placeValue = Decimal.fromInt(qDigit) * scale;
    print('scale: $scale');
    print('place_value: $placeValue');

    Decimal subtractVal = divisor * placeValue;
    remainingDividend -= subtractVal;
    print('remaining_dividend: $remainingDividend');
    print('modoshi: $modoshi');
    print('----------------------');

    // stop conditions
    if ((placeValue <= Decimal.parse('0.0009') && qDigit != 0) ||
        (i > decimalIndex && integerDividend)) {
      break;
    }
  }

  return {
    'quotient': quotient,
    'divisor': divisor,
    'dividend': dividend,
    'modoshi': modoshi,
  };
}

void main() {
  // var problems = DivMultProblemSet(level: DivMultLevel.zsdk8);

  // // Print each item individually to see they're strings
  // for (var problem in problems.formattedProblems) {
  //   print('Problem: "$problem" (type: ${problem.runtimeType})');
  // }

  // for (var answer in problems.formattedAnswers) {
  //   print('Answer: "$answer" (type: ${answer.runtimeType})');
  // }

  // // Or use join to print clearly
  // print('Problems: ${problems.formattedProblems.join(", ")}');
  // print('Answers: ${problems.formattedAnswers.join(", ")}');

  DivisionProblem problem = DivisionProblem(
    spec: DivMultSpec(
      digitCount: 8,
      problemType: .type4,
      split: [3, 5],
      intRound: false,
    ),
  );

  print(problem);
}
