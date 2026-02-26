import 'package:soroban_app/models/level_definitions.dart';

abstract interface class AloudSpec {
  int get minDigits;
  int get maxDigits;
  int get kuchi;
  int get msPerMora;
  double get secondsPerInterval;
  int get probCount;
  int? get minusCount;
}

class AloudSingleProblemSpec implements AloudSpec {
  @override
  int kuchi;
  @override
  int minDigits;
  @override
  int maxDigits;
  @override
  int msPerMora;
  @override
  double secondsPerInterval;
  @override
  int probCount;
  @override
  int? minusCount;

  AloudSingleProblemSpec({
    required this.minDigits,
    required this.maxDigits,
    required this.kuchi,
    required this.msPerMora,
    required this.secondsPerInterval,
    this.probCount = 1,
    this.minusCount,
  });
}

enum AloudLevel implements AloudSpec {
  zsk10(
    kuchi: 5,
    minDigits: 1,
    maxDigits: 1,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 0,
  ),
  zsk9(
    kuchi: 5,
    minDigits: 1,
    maxDigits: 2,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 0,
  ),
  zsk8(
    kuchi: 5,
    minDigits: 2,
    maxDigits: 2,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 1,
  ),
  zsk7(
    kuchi: 5,
    minDigits: 2,
    maxDigits: 3,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 1,
  ),
  zsk6(
    kuchi: 7,
    minDigits: 3,
    maxDigits: 3,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 2,
  ),
  zsk5(
    kuchi: 7,
    minDigits: 3,
    maxDigits: 4,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 2,
  ),
  zsk4(
    kuchi: 7,
    minDigits: 4,
    maxDigits: 4,
    msPerMora: 200,
    secondsPerInterval: 1.5,
    minusCount: 2,
  ),
  zsk3(
    kuchi: 10,
    minDigits: 3,
    maxDigits: 5,
    msPerMora: 200,
    secondsPerInterval: 1,
    minusCount: 3,
  ),
  zsk2(
    kuchi: 10,
    minDigits: 3,
    maxDigits: 6,
    msPerMora: 175,
    secondsPerInterval: 1,
    minusCount: 3,
  ),
  zsk1(
    kuchi: 10,
    minDigits: 4,
    maxDigits: 7,
    msPerMora: 175,
    secondsPerInterval: 1,
    minusCount: 3,
  ),
  zsd1(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 7,
    msPerMora: 175,
    secondsPerInterval: 0.5,
    minusCount: 3,
  ),
  zsd2(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 8,
    msPerMora: 175,
    secondsPerInterval: 0.5,
    minusCount: 3,
  ),
  zsd3(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 9,
    msPerMora: 175,
    secondsPerInterval: 0.5,
    minusCount: 3,
  ),
  zsd4(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 10,
    msPerMora: 175,
    secondsPerInterval: 0.5,
    minusCount: 3,
  ),
  zsd5(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 11,
    msPerMora: 175,
    secondsPerInterval: 0,
    minusCount: 3,
  ),
  zsd6(
    kuchi: 10,
    minDigits: 7,
    maxDigits: 12,
    msPerMora: 150,
    secondsPerInterval: 0,
    minusCount: 3,
  ),
  zsd7(
    kuchi: 10,
    minDigits: 7,
    maxDigits: 13,
    msPerMora: 125,
    secondsPerInterval: 0,
    minusCount: 3,
  ),
  zsd8(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 14,
    msPerMora: 125,
    secondsPerInterval: 0,
    minusCount: 5,
  ),
  zsd9(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 15,
    msPerMora: 100,
    secondsPerInterval: 0,
    minusCount: 5,
  ),
  zsd10(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 16,
    msPerMora: 75,
    secondsPerInterval: 0,
    minusCount: 5,
  );

  @override
  final int kuchi;
  @override
  final int minDigits;
  @override
  final int maxDigits;
  @override
  final int msPerMora;
  @override
  final double secondsPerInterval;
  @override
  final int probCount = 5;
  @override
  final int? minusCount;

  const AloudLevel({
    required this.minDigits,
    required this.maxDigits,
    required this.kuchi,
    required this.msPerMora,
    required this.secondsPerInterval,
    required this.minusCount,
  });
}
