import 'package:soroban_app/problem_generation/flash_set.dart';

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

enum FlashLevel implements FlashSpec {
  zsk20(
    kuchi: 1,
    digits: 1,
    secondsPerProblem: 2,
    probCount: 15,
    builder: noCarry,
  ),
  zsk19(
    kuchi: 2,
    digits: 1,
    secondsPerProblem: 4,
    probCount: 15,
    builder: zsk19Builder,
  ),
  zsk18(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
  ),
  zsk17(
    kuchi: 4,
    digits: 1,
    secondsPerProblem: 8,
    probCount: 15,
    builder: noCarry,
  ),
  zsk16(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 15,
    builder: noCarry,
  ),
  zsk15(
    kuchi: 6,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
  ),
  zsk14(
    kuchi: 8,
    digits: 1,
    secondsPerProblem: 8,
    probCount: 15,
    builder: noCarry,
  ),
  zsk13(
    kuchi: 10,
    digits: 1,
    secondsPerProblem: 10,
    probCount: 15,
    builder: noCarry,
  ),
  zsk12(
    kuchi: 12,
    digits: 1,
    secondsPerProblem: 12,
    probCount: 15,
    builder: noCarry,
  ),
  zsk11(
    kuchi: 10,
    digits: 1, // uses x10 builder
    secondsPerProblem: 10,
    probCount: 15,
    builder: multiplierBuilder,
    multiplier: 10,
  ),
  zsk10(
    kuchi: 4,
    digits: 1,
    secondsPerProblem: 4,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
  ),
  zsk9(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
  ),
  zsk8(
    kuchi: 6,
    digits: 1,
    secondsPerProblem: 6,
    probCount: 15,
    builder: noCarry,
    someCarriesAllowed: true,
  ),
  zsk7(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 3,
    probCount: 15,
    builder: zsk7Builder,
  ),
  zsk6(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 3,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsk5(
    kuchi: 4,
    digits: 2,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsk4(
    kuchi: 5,
    digits: 2,
    secondsPerProblem: 5,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsk3(
    kuchi: 6,
    digits: 2,
    secondsPerProblem: 5,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsk2(
    kuchi: 8,
    digits: 2,
    secondsPerProblem: 7,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsk1(
    kuchi: 10,
    digits: 2,
    secondsPerProblem: 8,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd1(
    kuchi: 4,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd2(
    kuchi: 5,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd3(
    kuchi: 6,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd4(
    kuchi: 7,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd5(
    kuchi: 8,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd6(
    kuchi: 9,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd7(
    kuchi: 10,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd8(
    kuchi: 12,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd9(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 15,
    builder: mitoriStyle,
  ),
  zsd10(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 3,
    probCount: 15,
    builder: mitoriStyle,
  ),
  kkk20(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 10,
    builder: noCarry,
    constrainUnder4: true,
  ),
  kkk19(
    kuchi: 3,
    digits: 1,
    secondsPerProblem: 5,
    probCount: 10,
    builder: kkk19Builder,
  ),
  kkk18(
    kuchi: 5,
    digits: 1,
    secondsPerProblem: 7,
    probCount: 10,
    builder: noCarry,
  ),
  kkk17(
    kuchi: 8,
    digits: 1,
    secondsPerProblem: 10,
    probCount: 10,
    builder: noCarry,
  ),
  kkk16(
    kuchi: 10,
    digits: 1,
    secondsPerProblem: 12,
    probCount: 10,
    builder: noCarry,
  ),
  kkk15(
    kuchi: 12,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
  ),
  kkk14(
    kuchi: 15,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
  ),
  kkk13(
    kuchi: 20,
    digits: 1,
    secondsPerProblem: 15,
    probCount: 10,
    builder: noCarry,
  ),
  kkk12(
    kuchi: 10,
    digits: 1, // uses x10 builder
    secondsPerProblem: 10,
    probCount: 10,
    builder: multiplierBuilder,
    multiplier: 10,
  ),
  kkk11(
    kuchi: 15,
    digits: 1, // uses x11 builder
    secondsPerProblem: 15,
    probCount: 10,
    builder: multiplierBuilder,
    multiplier: 11,
  ),
  kkk10(
    kuchi: 2,
    digits: 2,
    secondsPerProblem: 4,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk9(
    kuchi: 3,
    digits: 2,
    secondsPerProblem: 6,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk8(
    kuchi: 4,
    digits: 2,
    secondsPerProblem: 7,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk7(
    kuchi: 5,
    digits: 2,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk6(
    kuchi: 6,
    digits: 2,
    secondsPerProblem: 9,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk5(
    kuchi: 7,
    digits: 2,
    secondsPerProblem: 10,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk4(
    kuchi: 8,
    digits: 2,
    secondsPerProblem: 11,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk3(
    kuchi: 10,
    digits: 2,
    secondsPerProblem: 12,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk2(
    kuchi: 12,
    digits: 2,
    secondsPerProblem: 12,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkk1(
    kuchi: 15,
    digits: 2,
    secondsPerProblem: 13,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkd1(
    kuchi: 15,
    digits: 2,
    secondsPerProblem: 10,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd2(
    kuchi: 4,
    digits: 3,
    secondsPerProblem: 4,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkd3(
    kuchi: 6,
    digits: 3,
    secondsPerProblem: 5,
    probCount: 10,
    builder: mitoriStyle, // no 2-carries, might have to change this later.
  ),
  kkd4(
    kuchi: 8,
    digits: 3,
    secondsPerProblem: 6,
    probCount: 10,
    builder:
        mitoriStyle, // no 2-carries, might have to change this later. This seems to be the last level without 2-carries.
  ),
  kkd5(
    kuchi: 10,
    digits: 3,
    secondsPerProblem: 7,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd6(
    kuchi: 12,
    digits: 3,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd7(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 8,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd8(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 6,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd9(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 4.5,
    probCount: 10,
    builder: mitoriStyle,
  ),
  kkd10(
    kuchi: 15,
    digits: 3,
    secondsPerProblem: 3,
    probCount: 10,
    builder: mitoriStyle,
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
}
