import 'dart:math';
import 'package:decimal/decimal.dart';
import 'generation_spec.dart';

class DivisionProblem {
  final Decimal dividend;
  final Decimal divisor;
  final Decimal quotient;

  // Private generative constructor
  DivisionProblem._(this.dividend, this.divisor, this.quotient);

  // Factory constructor that retries until success
  factory DivisionProblem({required DivisionSpec spec}) {
    final rand = Random();

    if (spec.integerDividend) {
      while (true) {
        var split = _splitDigits(spec.digitCount);
        int dDigits = split.dDigits;
        int qDigits = split.qDigits;

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
      } //TODO: Figure out unneat generation
    } else {
      var split = _splitDigits(spec.digitCount);
      int dDigits = split.dDigits;
      int qDigits = split.qDigits;

      Decimal divisor = _randomDecimal(dDigits);
      Decimal quotient = _randomDecimal(qDigits);
      Decimal dividend = divisor * quotient;

      if (spec.hasDecimals) {
        divisor = _scaleValue(divisor);
        quotient = _scaleValue(quotient, avoidSmallQuotient: true);
        dividend = divisor * quotient;
      }

      return DivisionProblem._(dividend, divisor, quotient);
    }
  }

  // Random decimal with given digits
  static Decimal _randomDecimal(int digits) {
    int low, high;
    if (digits == 1) {
      low = 2;
      high = 9;
    } else {
      low = pow(10, digits - 1).toInt();
      high = pow(10, digits).toInt() - 1;
    }
    int value = low + Random().nextInt(high - low + 1);
    return Decimal.fromInt(value);
  }

  static Decimal _scaleValue(Decimal val, {bool avoidSmallQuotient = false}) {
    var intDigits = val.toString().split('.')[0].length;
    int maxPower = avoidSmallQuotient ? intDigits - 2 : intDigits + 1;

    if (maxPower > 0) {
      int scalePower = 1 + Random().nextInt(maxPower);
      Decimal divisor = Decimal.fromInt(pow(10, scalePower).toInt());
      return (val / divisor).toDecimal();
    }
    return val;
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
    if (den <= 0) throw ArgumentError('den must be positive');
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
    if (den <= 0) throw ArgumentError('den must be positive');

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

  static ({int dDigits, int qDigits}) _splitDigits(int totalDigits) {
    var first = Random().nextInt(totalDigits - 3) + 2;
    var second = totalDigits - first;
    return (dDigits: first, qDigits: second);
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

    // Remove leading zeros and decimal points
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
  var spec1 = DivisionSpec(digitCount: 6, integerDividend: true);
  var problem1 = DivisionProblem(spec: spec1);
  print("Problem 1:");
  print(problem1);
  print("");

  // Example 2: Generate a problem with decimals allowed
  var spec2 = DivisionSpec(
    digitCount: 5,
    integerDividend: false,
    hasDecimals: true,
  );
  var problem2 = DivisionProblem(spec: spec2);
  print("Problem 2:");
  print(problem2);
  print("");

  // Example 3: Generate a larger problem
  var spec3 = DivisionSpec(digitCount: 8, integerDividend: false);
  var problem3 = DivisionProblem(spec: spec3);
  print("Problem 3:");
  print(problem3);
}
