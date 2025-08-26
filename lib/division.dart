import 'dart:math';
import 'package:decimal/decimal.dart';

class DivisionProblem {
  final int digitCount;
  final bool controlDigitSplit;
  final bool integerDividend;
  final bool decimals;
  late Decimal divisor;
  late Decimal quotient;
  late Decimal dividend;

  DivisionProblem({
    required this.digitCount,
    this.controlDigitSplit = false,
    this.integerDividend = false,
    this.decimals = false,
    int? seed,
  }) {
    if (seed != null) {
      Random(seed);
    }

    int maxAttempts = 100;
    for (var i = 0; i < maxAttempts; i++) {
      var split = _splitDigits(digitCount);
      int dDigits = split.item1;
      int qDigits = split.item2;

      divisor = _randomDecimal(dDigits);
      quotient = _randomDecimal(qDigits);
      dividend = divisor * quotient;

      if (integerDividend) {
        if (decimals) {
          divisor = _scaleValue(divisor);
          quotient = _scaleValue(quotient, avoidSmallQuotient: true);
          dividend = divisor * quotient;

          // ensure dividend is integer
          dividend = Decimal.fromInt(dividend.toBigInt().toInt());
          quotient = (dividend / divisor).toDecimal(
            scaleOnInfinitePrecision: 50,
          );
          quotient = Decimal.fromInt(quotient.toBigInt().toInt());
        }
      } else {
        if (decimals) {
          divisor = _scaleValue(divisor);
          quotient = _scaleValue(quotient);
          dividend = divisor * quotient;
        }
      }

      if ((!integerDividend) ||
          (quotient.toString().length >= (digitCount / 3).ceil() &&
              dividend.toString().length >= (digitCount / 3).ceil())) {
        break;
      }
    }
  }

  ({int item1, int item2}) _splitDigits(int totalDigits) {
    if (controlDigitSplit) {
      return (item1: 3, item2: totalDigits - 3);
    } else {
      var first = Random().nextInt(totalDigits - 3) + 2;
      var second = totalDigits - first;
      return (item1: first, item2: second);
    }
  }

  Decimal _randomDecimal(int digits) {
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

  Decimal _scaleValue(Decimal val, {bool avoidSmallQuotient = false}) {
    var intDigits = val.toString().split('.')[0].length;
    int maxPower = avoidSmallQuotient ? intDigits - 2 : intDigits + 1;

    if (maxPower > 0) {
      int scalePower = 1 + Random().nextInt(maxPower);
      Decimal divisor = Decimal.fromInt(pow(10, scalePower).toInt());
      return (val / divisor).toDecimal(scaleOnInfinitePrecision: 50);
    }
    return val;
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

    if (qCh == '.') continue; // Skip decimals after first sig fig

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
  var p2 = DivisionProblem(
    digitCount: 5,
    controlDigitSplit: false,
    integerDividend: false,
    decimals: true,
  );
  print(p2);
  calculateDivisionDifficulty(
    p2.dividend,
    p2.divisor,
    p2.quotient,
    p2.integerDividend,
  );
}
