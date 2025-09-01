class GenerationSpec {
  bool? allowMinus; // Flash, Variable Digits
  bool? digitAllDifferent;
  bool? neverNegative;
  int? probCount;
  int? digitCount; // Flash, Division, and Multiplication
  int? length; // Flash
  bool? integerDividend; // Division
  bool? decimals; // Division and Multiplication
  bool? controlDigitSplit; // Division and Multiplication
  List<Map<String, int>>? problemSpec; // Variable Digits

  GenerationSpec({
    this.allowMinus,
    this.digitAllDifferent,
    this.neverNegative,
    this.probCount,
    this.digitCount,
    this.integerDividend,
    this.decimals,
    this.controlDigitSplit,
    this.problemSpec,
  });
}

final kyuu_dan_spec = {
  "10kyuu": {"digitCount": 3, "probCount": 5, "allowMinus": false},
  "9kyuu": {"digitCount": 5, "probCount": 10, "allowMinus": true},
  "8kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "7kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "6kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "5kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "4kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "3kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "2kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
  "1kyuu": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
    "neverNegative": true,
    "problemSpec": [
      {'digits': 3, 'count': 3},
      {'digits': 4, 'count': 2},
      {'digits': 5, 'count': 2},
      {'digits': 6, 'count': 3},
      {'minusCount': 3},
      {'probCount': 15},
    ],
  },
  "dan": {
    "digitCount": 6,
    "probCount": 20,
    "allowMinus": true,
    "decimals": true,
  },
};

GenerationSpec getSpec(Map<String, dynamic> config) {
  return GenerationSpec(
    allowMinus: config["allowMinus"],
    digitAllDifferent: config["digitAllDifferent"],
    neverNegative: config["neverNegative"],
    probCount: config["probCount"],
    digitCount: config["digitCount"],
    integerDividend: config["integerDividend"],
    decimals: config["decimals"],
    controlDigitSplit: config["controlDigitSplit"],
    problemSpec: config["problemSpec"],
  );
}
