import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'generation_spec.dart';

int _decimalPlaces(var number) {
  final str = number.toString();
  if (!str.contains('.')) return 0;
  return str.split('.')[1].length;
}

String formatDecimal(Decimal number) {
  final decimals = _decimalPlaces(number);
  final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
  final formatter = NumberFormat(pattern);
  return formatter.format(number.toDouble());
}

String formatInt(int number) {
  final pattern = '#,##0';
  final formatter = NumberFormat(pattern);
  return formatter.format(number);
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

  final min = BigInt.from(10).pow(digits - 1);
  final max = BigInt.from(10).pow(digits) - BigInt.one;

  final range = max - min + BigInt.one;
  BigInt n = min + BigInt.from(rand.nextInt(range.toInt()));

  return Decimal.fromBigInt(n);
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

({int firstDigits, int secondDigits}) splitDigits(
  var spec, {
  Map<String, dynamic>? digitSplit,
  required final int secondDigits,
  required final int firstDigits,
}) {
  final rand = Random();

  if (digitSplit != null && digitSplit.containsKey(spec.difficulty)) {
    final difficultySpec = digitSplit[spec.difficulty]!;

    if (difficultySpec.containsKey(spec.digitCount)) {
      final entry = difficultySpec[spec.digitCount]!;

      if (entry is List<int>) {
        return (firstDigits: entry[0], secondDigits: entry[1]);
      }

      if (entry is List<List<int>>) {
        final choice = entry[rand.nextInt(entry.length)];
        return (firstDigits: choice[0], secondDigits: choice[1]);
      }
    }
  }

  // --- fallback if no matching difficulty OR no matching digitCount ---
  int a = (spec.digitCount / 3).floor();
  int b = spec.digitCount - a;
  return (firstDigits: a, secondDigits: b);
}
