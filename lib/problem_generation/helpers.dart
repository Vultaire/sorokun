import 'dart:math';
import 'package:decimal/decimal.dart';

String formatWithCommas(String text) {
  if (text.isEmpty || text.length <= 3) return text;

  bool isNegative = text.startsWith('-');
  if (isNegative) {
    text = text.substring(1);
  }

  List<String> parts = text.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  int totalDigits = integerPart.replaceAll('b', '').length;

  StringBuffer formatted = StringBuffer();
  int digitCount = 0;

  for (int i = 0; i < integerPart.length; i++) {
    String ch = integerPart[i];
    if (ch == 'b') {
      formatted.write(ch);
      continue;
    }

    if (digitCount > 0 && (totalDigits - digitCount) % 3 == 0) {
      formatted.write(',');
    }
    formatted.write(ch);
    digitCount++;
  }

  if (decimalPart.isNotEmpty) {
    formatted.write('.');
    formatted.write(decimalPart);
  } else if (parts.length > 1) {
    formatted.write('.');
  }

  if (isNegative) {
    return '-${formatted.toString()}';
  }

  return formatted.toString();
}

int getRandomFlashDigit(Random rand, {List<int> excepts = const []}) {
  final available = <int>[];
  for (int i = 0; i < 10; i++) {
    if (!excepts.contains(i)) {
      available.add(i);
    }
  }
  return available[rand.nextInt(available.length)];
}

int getRandomFlashInt(
  int digitCount,
  List<int> allPreviousNums,
  int? previousNum,
) {
  final rand = Random();
  final previousNumDigits = previousNum == null
      ? <int>[]
      : previousNum.abs().toString().split('').map(int.parse).toList();

  while (true) {
    List<int> firstExcepts = [0];
    if (previousNumDigits.isNotEmpty) {
      firstExcepts.add(previousNumDigits.first);
    }
    int firstDigit = getRandomFlashDigit(rand, excepts: firstExcepts);

    final digits = <int>[firstDigit];

    for (int i = 1; i < digitCount; i++) {
      List<int> excepts = [];
      if (previousNumDigits.length > i) {
        excepts.add(previousNumDigits[i]);
      }
      excepts.addAll(digits);
      int nextDigit = getRandomFlashDigit(rand, excepts: excepts);
      digits.add(nextDigit);
    }

    int number = int.parse(digits.join());

    return number;
  }
}

Decimal randomDecimal(int digits, Random rand) {
  late String result;

  if (digits == 1) {
    // single digit can't be 0 or 1, too easy.
    result = (2 + rand.nextInt(8)).toString();
  } else {
    // First digit can't be 0
    result = (1 + rand.nextInt(9)).toString();

    // Remaining digits can be 0-9
    for (int i = 1; i < digits; i++) {
      result += rand.nextInt(10).toString();
    }
  }

  return Decimal.parse(result);
}

Decimal randomDecimalNoTrailingZero(int digits, Random rand) {
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
    value = low + rand.nextInt(high - low + 1);
  } while (value % 10 == 0);

  return Decimal.fromInt(value);
}

(Decimal, int) scaleValue(
  Decimal value,
  Random rand, {
  bool avoidScaleOverThree = false,
  bool avoidScaleOverValueDigits = false,
}) {
  final String valueString = value.toString();
  final int valueDigits = valueString.length;
  int maxPower;

  if (avoidScaleOverValueDigits) {
    maxPower = valueDigits;
  } else if (avoidScaleOverThree) {
    maxPower = 3;
  } else {
    maxPower = valueDigits + 1;
  }

  int scalePower = rand.nextInt(maxPower) + 1;

  Decimal unscaledValue = value;

  if (scalePower > valueDigits) {
    unscaledValue = Decimal.parse(
      valueString.substring(0, valueDigits - (scalePower - valueDigits)),
    );
    scalePower -= (scalePower - valueDigits);
  }

  return (unscaledValue.shift(-scalePower), scalePower);
}

void main() {
  print(scaleValue(Decimal.parse('255'), Random()));
}
