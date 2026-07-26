import 'dart:math';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/mitori.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';

class AloudProblemSet {
  late final List<MitoriProblem> mitoriProblemList;

  AloudProblemSet({required AloudSpec spec}) {
    final Random rand = Random();
    final List<MitoriProblem> templateProblems = List.generate(
      spec.probCount,
      (_) => MitoriProblem(
        generateMitoriProblemFromDigitList(
          generateDigitList(
            minDigits: spec.minDigits,
            maxDigits: spec.maxDigits,
            kuchi: spec.kuchi,
            rand: rand,
          ),
          rand,
        ),
      ),
    );

    final int minusCount = spec.minusCount ?? (spec.kuchi / 3).ceil();
    applyZenshurenMinus(
      templateProblems: templateProblems,
      isNeverNegative: true,
      minusProblemsPerTemplate: 2,
      problemsPerTemplate: spec.probCount,
      regenerateProblem: (rand) {
        final randomLayout = generateDigitList(
          minDigits: spec.minDigits,
          maxDigits: spec.maxDigits,
          kuchi: spec.kuchi,
          rand: rand,
        );
        return generateMitoriProblemFromDigitList(randomLayout, rand);
      },
      minusCount: minusCount,
      rand: rand,
    );

    mitoriProblemList = templateProblems;
  }
  List<List<int>> get unformattedProblems =>
      mitoriProblemList.map((i) => i.problem).toList();
  List<List<String>> get formattedProblems =>
      mitoriProblemList.map((i) => i.formattedProblem).toList();
  List<String> get formattedAnswers =>
      mitoriProblemList.map((i) => i.formattedAnswer).toList();
}

List<int> generateDigitList({
  required int minDigits,
  required int maxDigits,
  required int kuchi,
  required Random rand,
}) {
  assert(minDigits <= maxDigits);

  final fullRange = [for (int i = minDigits; i <= maxDigits; i++) i];

  final filling = [for (int i = minDigits + 1; i < maxDigits; i++) i]
    ..shuffle(rand);

  while (filling.length < kuchi - 2) {
    filling.addAll(List<int>.from(fullRange)..shuffle(rand));
  }

  return [minDigits, maxDigits, ...filling.take(kuchi - 2)]..shuffle(rand);
}

void main() {
  print(
    generateDigitList(minDigits: 2, maxDigits: 5, kuchi: 4, rand: Random()),
  );
}
