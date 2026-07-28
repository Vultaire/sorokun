part of 'package:soroban_app/models/level_definitions.dart';

abstract interface class FlashSpec {
  int get digits;
  int get kuchi;
  double get secondsPerProblem;
  Function get builder;
  int get probCount;
}

class FlashSingleProblemSpec implements FlashSpec {
  @override
  int kuchi;
  @override
  int digits;
  @override
  double secondsPerProblem;
  @override
  Function builder;
  @override
  int probCount;

  FlashSingleProblemSpec({
    required this.digits,
    required this.kuchi,
    required this.secondsPerProblem,
    required this.builder,
    this.probCount = 1,
  });
}

enum FlashLevel implements FlashSpec, Level {
  zsk20(
    kuchi: 1,
    digits: 1,
    secondsPerProblem: 2,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk19(
    kuchi: 2,
    digits: 1,
    secondsPerProblem: 4,
    probCount: 15,
    builder: zsk19Builder,
    levelInfo: .zsflash,
  ),
  zsk18(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk17(
    kuchi: 4,
    digits: 1,
    secondsPerProblem: 8,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk16(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk15(
    kuchi: 6,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk14(
    kuchi: 8,
    digits: 1,
    secondsPerProblem: 8,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk13(
    kuchi: 10,
    digits: 1,
    secondsPerProblem: 10,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk12(
    kuchi: 12,
    digits: 1,
    secondsPerProblem: 12,
    probCount: 15,
    builder: noCarry,
    levelInfo: .zsflash,
  ),
  zsk11(
    kuchi: 10,
    digits: 1, // uses x10 builder
    secondsPerProblem: 10,
    probCount: 15,
    builder: multiplierBuilder,
    multiplier: 10,
    levelInfo: .zsflash,
  ),
  zsk10(
    kuchi: 4,
    digits: 1,
    secondsPerProblem: 4,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
    levelInfo: .zsflash,
  ),
  zsk9(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
    levelInfo: .zsflash,
  ),
  zsk8(
    kuchi: 6,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
    levelInfo: .zsflash,
  ),
  zsk7(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 3,
    probCount: 15,
    builder: zsk7Builder,
    levelInfo: .zsflash,
  ),
  zsk6(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 3,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsk5(
    kuchi: 4,
    digits: 2,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsk4(
    kuchi: 5,
    digits: 2,
    secondsPerProblem: 5,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsk3(
    kuchi: 6,
    digits: 2,
    secondsPerProblem: 5,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsk2(
    kuchi: 8,
    digits: 2,
    secondsPerProblem: 7,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsk1(
    kuchi: 10,
    digits: 2,
    secondsPerProblem: 8,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd1(
    kuchi: 4,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd2(
    kuchi: 5,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd3(
    kuchi: 6,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd4(
    kuchi: 7,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd5(
    kuchi: 8,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd6(
    kuchi: 9,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd7(
    kuchi: 10,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd8(
    kuchi: 12,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd9(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  zsd10(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 3,
    probCount: 15,
    builder: mitoriStyle,
    levelInfo: .zsflash,
  ),
  kkk20(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 10,
    builder: noCarry,
    constrainUnder4: true,
    levelInfo: .kkflash,
  ),
  kkk19(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 10,
    builder: kkk19Builder,
    levelInfo: .kkflash,
  ),
  kkk18(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 7,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk17(
    kuchi: 8,
    digits: 1,
    secondsPerProblem: 10,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk16(
    kuchi: 10,
    digits: 1,
    secondsPerProblem: 12,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk15(
    kuchi: 12,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk14(
    kuchi: 15,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk13(
    kuchi: 20,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
    levelInfo: .kkflash,
  ),
  kkk12(
    kuchi: 10,
    digits: 1, // uses x10 builder
    secondsPerProblem: 10,
    probCount: 10,
    builder: multiplierBuilder,
    multiplier: 10,
    levelInfo: .kkflash,
  ),
  kkk11(
    kuchi: 15,
    digits: 1, // uses x11 builder
    secondsPerProblem: 15,
    probCount: 10,
    builder: multiplierBuilder,
    multiplier: 11,
    levelInfo: .kkflash,
  ),
  kkk10(
    kuchi: 2,
    digits: 2,
    secondsPerProblem: 4,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk9(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 6,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk8(
    kuchi: 4,
    digits: 2,
    secondsPerProblem: 7,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk7(
    kuchi: 5,
    digits: 2,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk6(
    kuchi: 6,
    digits: 2,
    secondsPerProblem: 9,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk5(
    kuchi: 7,
    digits: 2,
    secondsPerProblem: 10,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk4(
    kuchi: 8,
    digits: 2,
    secondsPerProblem: 11,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk3(
    kuchi: 10,
    digits: 2,
    secondsPerProblem: 12,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk2(
    kuchi: 12,
    digits: 2,
    secondsPerProblem: 12,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkk1(
    kuchi: 15,
    digits: 2,
    secondsPerProblem: 13,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkd1(
    kuchi: 15,
    digits: 2,
    secondsPerProblem: 10,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd2(
    kuchi: 4,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkd3(
    kuchi: 6,
    digits: 3,
    secondsPerProblem: 5,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries,
    levelInfo: .kkflash,
  ),
  kkd4(
    kuchi: 8,
    digits: 3,
    secondsPerProblem: 6,
    probCount: 10,
    builder:
        mitoriStyle, // no 2-carries, might have to change this later. This seems to be the last level without 2-carries.
    levelInfo: .kkflash,
  ),
  kkd5(
    kuchi: 10,
    digits: 3,
    secondsPerProblem: 7,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd6(
    kuchi: 12,
    digits: 3,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd7(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd8(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 6,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd9(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 4.5,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  ),
  kkd10(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 3,
    probCount: 10,
    builder: mitoriStyle,
    levelInfo: .kkflash,
  );

  const FlashLevel({
    required this.kuchi,
    required this.digits,
    required this.secondsPerProblem,
    required this.probCount,
    required this.builder,
    this.someCarriesAllowed = false,
    this.constrainUnder4 = false,
    this.multiplier = 0,
    required this.levelInfo,
  });
  @override
  final int kuchi;
  @override
  final int digits;
  @override
  final double secondsPerProblem;
  @override
  final int probCount;
  @override
  final Function builder;
  final bool someCarriesAllowed;
  final bool constrainUnder4;
  final int multiplier;
  @override
  final LevelInfo levelInfo;
  bool get kuriagariNashi => builder != mitoriStyle;
  @override
  get maxDigits => digits;
}
