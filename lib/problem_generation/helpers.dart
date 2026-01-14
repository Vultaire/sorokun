import 'dart:math';

import 'package:decimal/decimal.dart';
import 'generation_spec.dart';

String formatWithCommas(String text) {
  if (text.isEmpty) return text;

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

    // Add comma before digit if needed
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

int getRandomDigit(Random rand, {List<int> excepts = const []}) {
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
  FlashSpec spec,
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
    int firstDigit = getRandomDigit(rand, excepts: firstExcepts);

    final digits = <int>[firstDigit];

    for (int i = 1; i < digitCount; i++) {
      List<int> excepts = [];
      if (previousNumDigits.length > i) {
        excepts.add(previousNumDigits[i]);
      }
      if (spec.digitAllDifferent) {
        excepts.addAll(digits);
      }
      int nextDigit = getRandomDigit(rand, excepts: excepts);
      digits.add(nextDigit);
    }

    int number = int.parse(digits.join());

    if (spec.allowMinus && rand.nextDouble() < 0.3) {
      if (spec.neverNegative &&
          number > allPreviousNums.fold(0, (a, b) => a + b)) {
        continue;
      }
      number = -number;
    }
    return number;
  }
}

int getRandomInt(int digitCount, bool digitAllDifferent, int? previousNum) {
  final rand = Random();

  while (true) {
    final digits = <int>[];

    for (int position = 0; position < digitCount; position++) {
      List<int> excepts = [];

      if (digitAllDifferent) {
        excepts.addAll(digits);
      }

      if (position == 0) {
        excepts.add(0);
      }

      // Calculate the place value for this position
      int placeValue = pow(10, digitCount - 1 - position).toInt();

      // If previousNum exists, find what digit is at this place value and exclude it
      if (previousNum != null) {
        int digitAtThisPlace = (previousNum ~/ placeValue) % 10;
        excepts.add(digitAtThisPlace);
      }

      int nextDigit = getRandomDigit(rand, excepts: excepts);
      digits.add(nextDigit);
    }

    int number = int.parse(digits.join());
    return number;
  }
}

Decimal randomDecimal(int digits) {
  final rand = Random();

  // First digit can't be 0
  String result = (1 + rand.nextInt(9)).toString();

  // Remaining digits can be 0-9
  for (int i = 1; i < digits; i++) {
    result += rand.nextInt(10).toString();
  }

  return Decimal.parse(result);
}

Decimal randomDecimalNoTrailingZero(int digits) {
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

(Decimal, int) scaleValue(
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

({int firstDigits, int secondDigits}) splitDigits({
  required List<List<int>> split,
}) {
  final rand = Random();
  final selected = split[rand.nextInt(split.length)];

  return (firstDigits: selected[0], secondDigits: selected[1]);
}

void main() {
  print(formatWithCommas('45685b123'));
}
