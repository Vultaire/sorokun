import 'dart:math';

void main() {
  var problem = neatDecimalDivisionProblem(totalDigits: 6);
  print('Dividend: ${problem['dividend']}');
  print('Divisor: ${problem['divisor']}');
  print('Quotient: ${problem['quotient']}');
}

// gcd
int _gcd(int a, int b) {
  while (b != 0) {
    int t = a % b;
    a = b;
    b = t;
  }
  return a.abs();
}

// strip factor p from n and return (exponent, leftover)
Map<String, int> _stripFactor(int n, int p) {
  int e = 0;
  while (n % p == 0 && n != 0) {
    n ~/= p;
    e++;
  }
  return {'exp': e, 'rem': n};
}

// returns (a, b, rem) where den = 2^a * 5^b * rem and rem coprime to 10
Map<String, int> reducedDenominatorExponents(int den) {
  if (den <= 0) throw ArgumentError('den must be positive');
  var two = _stripFactor(den, 2);
  var five = _stripFactor(two['rem']!, 5);

  return {
    'a': two['exp']!, // exponent of 2 in reduced denominator
    'b': five['exp']!, // exponent of 5 in reduced denominator
    'rem': five['rem']!, // leftover factor (if >1 => repeating)
  };
}

// Generate a random numerator that guarantees EXACTLY k decimal places
// pick a denominator with max(a,b)=k, then pick numerator coprime to 10.
int randomNumeratorForExactlyK(
  int den,
  int k,
  int digitsBeforeDecimal,
  Random rand,
) {
  if (den <= 0) throw ArgumentError('den must be positive');

  int minNum = den * pow(10, digitsBeforeDecimal - 1).toInt();
  int maxNum = den * pow(10, digitsBeforeDecimal).toInt() - 1;

  int candidate() {
    int r = minNum + rand.nextInt(maxNum - minNum + 1); // numerator in range
    // ensure numerator is coprime with 10 to preserve decimal places
    while (_gcd(r, 10) != 1) {
      r = minNum + rand.nextInt(maxNum - minNum + 1);
    }
    return r;
  }

  return candidate();
}

({int dDigits, int qDigits}) _splitDigits(int totalDigits) {
  var first = Random().nextInt(totalDigits - 3) + 2;
  var second = totalDigits - first;
  return (dDigits: first, qDigits: second);
}

int randomMultipleWithDigits(int den, int qDigits, Random rand) {
  int minK = (pow(10, qDigits - 1) / den).ceil();
  int maxK = (pow(10, qDigits) / den).floor() - 1;

  if (maxK < minK) {
    return -1;
  }

  int k = minK + rand.nextInt(maxK - minK + 1);

  return den * k;
}

// Helper: build a denominator that guarantees reduced max exponent == k,
// and has no other prime factors (so will always terminate)
int buildDenominatorForExactlyK({int a = 0, int b = 0}) {
  return (pow(2, a).toInt()) * (pow(5, b).toInt());
}

Map<String, num> neatDecimalDivisionProblem({required int totalDigits}) {
  final rand = Random();

  var split = _splitDigits(totalDigits);
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

  double divisor = numerator / denominator;

  int quotient = randomMultipleWithDigits(denominator, qDigits, rand);

  // Retry if generation failed
  if (quotient == -1) {
    return neatDecimalDivisionProblem(totalDigits: totalDigits);
  }

  double dividend = divisor * quotient;

  return <String, num>{
    'dividend': dividend,
    'divisor': divisor,
    'quotient': quotient,
  };
}
