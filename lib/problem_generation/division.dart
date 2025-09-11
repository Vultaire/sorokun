import 'dart:math';
import 'package:decimal/decimal.dart';
import 'generation_spec.dart';
import 'division_source.dart';

class DivisionProblem {
  final Decimal dividend;
  final Decimal divisor;
  final Decimal quotient;

  DivisionProblem._(this.dividend, this.divisor, this.quotient);

  factory DivisionProblem({required DivisionSpec spec}) {
    final rand = Random();
    final split = _splitDigits(
      spec,
      digitSplit: digitSplit,
      qDigits: 0,
      dDigits: 0,
    );
    final int dDigits = split.dDigits;
    final int qDigits = split.qDigits;

    if (spec.integerDividend && !spec.isUnneat) {
      return _integerDivisionNeat(spec, dDigits, qDigits, rand);
    } else if (spec.integerDividend && spec.isUnneat) {
      int divisorScale = 0;
      Decimal divisor = _randomDecimalNoTrailingZero(dDigits);
      (divisor, divisorScale) = _scaleValue(divisor);

      Decimal dividend = _randomDecimal(spec.digitCount - divisorScale);
      Decimal quotient = (dividend / divisor).round().toDecimal();

      int sigFigsDivisor = divisor
          .toString()
          .replaceFirst(RegExp(r'^0*\.?0*'), '')
          .replaceAll('.', '')
          .length;
      int sigFigsQuotient = quotient
          .toString()
          .replaceFirst(RegExp(r'^0*\.?0*'), '')
          .replaceAll('.', '')
          .length;
      int totalSigFigs = sigFigsDivisor + sigFigsQuotient;
      if (totalSigFigs < spec.digitCount) {
        int diff = spec.digitCount - totalSigFigs;
        dividend *= Decimal.fromInt(pow(10, diff).toInt());
        dividend = dividend.round();
      } else if (totalSigFigs > spec.digitCount) {
        int diff = totalSigFigs - spec.digitCount;
        dividend = (dividend / Decimal.fromInt(pow(10, diff).toInt()))
            .toDecimal();
        dividend = dividend.round();
      }
      quotient = (dividend / divisor).round().toDecimal();

      return DivisionProblem._(dividend, divisor, quotient);
    } else {
      Decimal divisor = _randomDecimalNoTrailingZero(dDigits);
      Decimal quotient = _randomDecimalNoTrailingZero(qDigits);
      Decimal dividend = divisor * quotient;

      if (spec.hasDecimals) {
        final (Decimal scaledDivisor, int _) = _scaleValue(divisor);
        divisor = scaledDivisor;

        if (spec.isUnneat) {
          final (Decimal scaledQuotient, int __) = _scaleValue(
            quotient,
            alwaysThree: true,
          );
          quotient = scaledQuotient;
          dividend = divisor * quotient;
          dividend = _makeDivisionUnneat(dividend, divisor, quotient);
        } else {
          final (Decimal scaledQuotient, int __) = _scaleValue(
            quotient,
            avoidOverScale: true,
          );
          quotient = scaledQuotient;
          dividend = divisor * quotient;
        }
      }

      return DivisionProblem._(dividend, divisor, quotient);
    }
  }

  static Decimal _randomDecimal(int digits) {
    final rand = Random();

    final min = BigInt.from(10).pow(digits - 1);
    final max = BigInt.from(10).pow(digits) - BigInt.one;

    final range = max - min + BigInt.one;
    BigInt n = min + BigInt.from(rand.nextInt(range.toInt()));

    return Decimal.fromBigInt(n);
  }

  static _integerDivisionNeat(
    DivisionSpec spec,
    int dDigits,
    int qDigits,
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

      return DivisionProblem._(dividend, divisor, quotient);
    }
  }

  static _makeDivisionUnneat(
    Decimal originalDividend,
    Decimal divisor,
    Decimal quotient,
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
    Random random = Random();
    double minPerturbationDouble = double.parse(minPerturbation.toString());
    double maxPerturbationDouble = double.parse(maxPerturbation.toString());
    double perturbationDouble =
        minPerturbationDouble +
        random.nextDouble() * (maxPerturbationDouble - minPerturbationDouble);

    Decimal perturbation = Decimal.parse(
      perturbationDouble.toStringAsFixed(10),
    );

    // Randomly choose to add or subtract the perturbation
    bool shouldAdd = random.nextBool();
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

  // Random decimal with given digits, never ends in zero
  static Decimal _randomDecimalNoTrailingZero(int digits) {
    int low, high;
    if (digits == 1) {
      low = 2;
      high = 9;
    } else {
      low = pow(10, digits - 1).toInt();
      high = pow(10, digits).toInt() - 1;
    }

    int value;
    do {
      value = low + Random().nextInt(high - low + 1);
    } while (value % 10 == 0);

    return Decimal.fromInt(value);
  }

  static (Decimal, int) _scaleValue(
    Decimal val, {
    bool avoidOverScale = false,
    bool alwaysThree = false,
    int scalePower = 0,
  }) {
    var intDigits = val.toString().split('.')[0].length;
    int maxPower = avoidOverScale ? 3 : intDigits + 1;

    if (maxPower > 0) {
      scalePower = alwaysThree ? 3 : 1 + Random().nextInt(maxPower);
      Decimal divisor = Decimal.fromInt(pow(10, scalePower).toInt());
      return ((val / divisor).toDecimal(), scalePower);
    }
    return (val, scalePower);
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

  static ({int dDigits, int qDigits}) _splitDigits(
    DivisionSpec spec, {
    Map<String, dynamic>? digitSplit,
    required final int qDigits,
    required final int dDigits,
  }) {
    final rand = Random();

    if (digitSplit != null && digitSplit.containsKey(spec.difficulty)) {
      final difficultySpec = digitSplit[spec.difficulty]!;

      if (difficultySpec.containsKey(spec.digitCount)) {
        final entry = difficultySpec[spec.digitCount]!;

        if (entry is List<int>) {
          return (dDigits: entry[0], qDigits: entry[1]);
        }

        if (entry is List<List<int>>) {
          final choice = entry[rand.nextInt(entry.length)];
          return (dDigits: choice[0], qDigits: choice[1]);
        }
      }
    }

    int a = (spec.digitCount / 3).floor();
    int b = spec.digitCount - a;

    return (dDigits: a, qDigits: b);
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

  @override
  String toString() {
    return 'dividend=$dividend, divisor=$divisor, quotient=$quotient';
  }
}

Map<String, dynamic> calculateDivisionDifficulty(
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

    if (qCh == '.') continue; // Skip hasDecimals after first sig fig

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
  // Example 1: Generate a problem with an integer dividend
  var spec1 = DivisionSpec(
    digitCount: 4,
    difficulty: "7kyuu",
    integerDividend: false,
    hasDecimals: false,
    isUnneat: false,
  );
  var problem1 = DivisionProblem(spec: spec1);
  print("Problem 1:");
  print(problem1);
  print("");

  // Example 2: Generate a problem with decimals allowed
  var spec2 = DivisionSpec(
    digitCount: 6,
    integerDividend: false,
    hasDecimals: true,
    isUnneat: false,
  );
  var problem2 = DivisionProblem(spec: spec2);
  print("Problem 2:");
  print(problem2);
  print("");

  // Example 3: Generate a larger problem
  var spec3 = DivisionSpec(
    digitCount: 9,
    integerDividend: true,
    hasDecimals: true,
    isUnneat: true,
  );
  var problem3 = DivisionProblem(spec: spec3);
  print("Problem 3:");
  print(problem3);
}
