import 'dart:math';

class AbacusDigit {
  final int value;
  final int five;
  final int one;

  AbacusDigit([this.value = 0, int? five, int? one])
    : five = five ?? value ~/ 5,
      one = one ?? value % 5;

  static AbacusDigit deepCopy(AbacusDigit d) =>
      AbacusDigit(d.value, d.five, d.one);

  @override
  String toString() => 'AbacusDigit(value=$value, five=$five, one=$one)';
}

class Abacus {
  final List<AbacusDigit> _digits = [];
  int _value = 0;
  int _carry = 0;

  Abacus([int n = 0]) {
    final initialLen = max(1, n.toString().length);
    for (var i = 0; i < initialLen; i++) {
      _digits.add(AbacusDigit());
    }
    add(n);
  }

  int get carry => _carry;
  int get value => _value;

  void updateBeads(int number) {
    final isNegative = number < 0;
    final numberArr = number.abs().toString().split('').map(int.parse).toList();

    for (int i = numberArr.length - 1; i >= 0; i--) {
      final d = numberArr.removeAt(0);
      if (d == 0) continue;

      while (i >= _digits.length) {
        _digits.add(AbacusDigit());
      }

      final beforeDigit = AbacusDigit.deepCopy(_digits[i]);
      int newVal = _digits[i].value;

      if (!isNegative) {
        newVal += d;
        if (newVal >= 10) {
          newVal -= 10;
          // Proper carry handling
          if (i + 1 >= _digits.length) _digits.add(AbacusDigit());
          _digits[i + 1] = AbacusDigit(
            _digits[i + 1].value + 1,
            (_digits[i + 1].value + 1) ~/ 5,
            (_digits[i + 1].value + 1) % 5,
          );
          _carry++;
        }
      } else {
        newVal -= d;
        if (newVal < 0) {
          newVal += 10;
          if (i + 1 >= _digits.length) _digits.add(AbacusDigit());
          _digits[i + 1] = AbacusDigit(
            _digits[i + 1].value - 1,
            (_digits[i + 1].value - 1) ~/ 5,
            (_digits[i + 1].value - 1) % 5,
          );
          _carry++;
        }
      }

      _digits[i] = AbacusDigit(newVal, newVal ~/ 5, newVal % 5);

      final fiveChange = _digits[i].five - beforeDigit.five;
      final oneChange = _digits[i].one - beforeDigit.one;

      if (fiveChange * oneChange < 0) _carry++;
    }
  }

  Abacus add(int number) {
    updateBeads(number);
    _value += number;
    return this;
  }

  List<int> digitsValues() => _digits.map((d) => d.value).toList();

  @override
  String toString() => 'Abacus(value=$_value, carry=$_carry, digits=$_digits)';
}

void main() {
  Abacus a1 = Abacus(0);
  a1.add(4);
  print(" ${a1.value}, carry: ${a1.carry}, digits: ${a1.digitsValues()}");
}
