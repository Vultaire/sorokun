part of 'package:soroban_app/models/level_definitions.dart';

abstract interface class AloudSpec {
  int get minDigits;
  int get maxDigits;
  int get kuchi;
  int get moraPerSecond;
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
  int moraPerSecond;
  @override
  double secondsPerInterval;
  @override
  int probCount;
  @override
  int minusCount;

  AloudSingleProblemSpec({
    required this.minDigits,
    required this.maxDigits,
    required this.kuchi,
    required this.moraPerSecond,
    required this.secondsPerInterval,
    this.probCount = 1,
    required this.minusCount,
  });
}

enum AloudLevel implements AloudSpec, Level {
  zsk10(
    kuchi: 5,
    minDigits: 1,
    maxDigits: 1,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 0,
    levelInfo: .zsAloud,
  ),
  zsk9(
    kuchi: 5,
    minDigits: 1,
    maxDigits: 2,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 0,
    levelInfo: .zsAloud,
  ),
  zsk8(
    kuchi: 5,
    minDigits: 2,
    maxDigits: 2,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 1,
    levelInfo: .zsAloud,
  ),
  zsk7(
    kuchi: 5,
    minDigits: 2,
    maxDigits: 3,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 1,
    levelInfo: .zsAloud,
  ),
  zsk6(
    kuchi: 7,
    minDigits: 3,
    maxDigits: 3,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 2,
    levelInfo: .zsAloud,
  ),
  zsk5(
    kuchi: 7,
    minDigits: 3,
    maxDigits: 4,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 2,
    levelInfo: .zsAloud,
  ),
  zsk4(
    kuchi: 7,
    minDigits: 4,
    maxDigits: 4,
    moraPerSecond: 5,
    secondsPerInterval: 1.5,
    minusCount: 2,
    levelInfo: .zsAloud,
  ),
  zsk3(
    kuchi: 10,
    minDigits: 3,
    maxDigits: 5,
    moraPerSecond: 5,
    secondsPerInterval: 1,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsk2(
    kuchi: 10,
    minDigits: 3,
    maxDigits: 6,
    moraPerSecond: 6,
    secondsPerInterval: 1,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsk1(
    kuchi: 10,
    minDigits: 4,
    maxDigits: 7,
    moraPerSecond: 6,
    secondsPerInterval: 1,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd1(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 7,
    moraPerSecond: 6,
    secondsPerInterval: 0.5,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd2(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 8,
    moraPerSecond: 6,
    secondsPerInterval: 0.5,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd3(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 9,
    moraPerSecond: 6,
    secondsPerInterval: 0.5,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd4(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 10,
    moraPerSecond: 6,
    secondsPerInterval: 0.5,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd5(
    kuchi: 10,
    minDigits: 5,
    maxDigits: 11,
    moraPerSecond: 6,
    secondsPerInterval: 0,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd6(
    kuchi: 10,
    minDigits: 7,
    maxDigits: 12,
    moraPerSecond: 7,
    secondsPerInterval: 0,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd7(
    kuchi: 10,
    minDigits: 7,
    maxDigits: 13,
    moraPerSecond: 8,
    secondsPerInterval: 0,
    minusCount: 3,
    levelInfo: .zsAloud,
  ),
  zsd8(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 14,
    moraPerSecond: 8,
    secondsPerInterval: 0,
    minusCount: 5,
    levelInfo: .zsAloud,
  ),
  zsd9(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 15,
    moraPerSecond: 10,
    secondsPerInterval: 0,
    minusCount: 5,
    levelInfo: .zsAloud,
  ),
  zsd10(
    kuchi: 15,
    minDigits: 7,
    maxDigits: 16,
    moraPerSecond: 12,
    secondsPerInterval: 0,
    minusCount: 5,
    levelInfo: .zsAloud,
  );

  @override
  final int kuchi;
  @override
  final int minDigits;
  @override
  final int maxDigits;
  @override
  final int moraPerSecond;
  @override
  final double secondsPerInterval;
  @override
  final int probCount = 5;
  @override
  final int minusCount;
  @override
  final LevelInfo levelInfo;
  bool get hasMinus => minusCount > 0;

  const AloudLevel({
    required this.minDigits,
    required this.maxDigits,
    required this.kuchi,
    required this.moraPerSecond,
    required this.secondsPerInterval,
    required this.minusCount,
    required this.levelInfo,
  });
}
