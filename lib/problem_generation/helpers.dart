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
  assert(digits <= 10, 'Cannot have more than 10 unique digits');

  if (digits == 1) {
    return Decimal.parse((2 + rand.nextInt(8)).toString());
  }

  List<int> available = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(rand);

  if (available[0] == 0) {
    int swapIndex = 1 + rand.nextInt(9);
    available[0] = available[swapIndex];
    available[swapIndex] = 0;
  }

  return Decimal.parse(available.take(digits).join());
}

Decimal randomDecimalNoTrailingZero(int digits, Random rand) {
  assert(digits <= 10, 'Cannot have more than 10 unique digits');

  if (digits == 1) {
    return Decimal.parse((2 + rand.nextInt(8)).toString());
  }

  List<int> available = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(rand);

  if (available[0] == 0) {
    int swapIndex = 1 + rand.nextInt(9);
    available[0] = available[swapIndex];
    available[swapIndex] = 0;
  }

  if (available[digits - 1] == 0) {
    int swapIndex;
    do {
      swapIndex = 1 + rand.nextInt(9);
    } while (swapIndex == digits - 1);
    available[digits - 1] = available[swapIndex];
    available[swapIndex] = 0;
  }

  return Decimal.parse(available.take(digits).join());
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
