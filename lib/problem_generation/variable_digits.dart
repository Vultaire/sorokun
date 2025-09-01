import 'dart:math';
import 'generation_spec.dart';

class VariableDigitsProblem {
  final GenerationSpec spec;
  late List<List<int>> allProblems = [];
  late List<int> sums = [];

  VariableDigitsProblem({required this.spec}) {
    final rand = Random();

    int randomInt(int digits) {
      int min = pow(10, digits - 1).toInt();
      int max = pow(10, digits).toInt() - 1;

      return min + rand.nextInt(max - min + 1);
    }

    for (int i = 0; i < (spec.probCount ?? 20); i++) {
      List<int> problem = [];
      for (var step in spec.problemSpec!) {
        if (step.containsKey('digits')) {
          int digits = step['digits']!;
          int count = step['count']!;
          for (int i = 0; i < count; i++) {
            problem.add(randomInt(digits));
          }
        } else if (step.containsKey('minusCount')) {
          int minusCount = step['minusCount']!;
          var minusIndices = List.generate(problem.length, (i) => i)
            ..shuffle(rand);

          if (spec.neverNegative ?? false) {
            bool ok = false;

            while (!ok) {
              problem.shuffle(rand);
              problem = problem.map((x) => x.abs()).toList();

              for (var i in minusIndices.take(minusCount)) {
                problem[i] = -problem[i].abs();
              }

              int runningSum = 0;
              ok = true;
              for (var n in problem) {
                runningSum += n;
                if (runningSum < 0) {
                  ok = false;
                  minusIndices = List.generate(problem.length, (i) => i)
                    ..shuffle(rand);
                  break;
                }
              }
            }
          } else {
            for (var i in minusIndices.take(minusCount)) {
              problem[i] = -problem[i].abs();
            }
          }
        }
      }
      allProblems.add(problem);
      sums.add(problem.reduce((a, b) => a + b));
    }
  }
}

void main() {
  var problem = VariableDigitsProblem(
    spec: getSpec(kyuu_dan_spec["1kyuu"] as Map<String, dynamic>),
  );

  print(problem.allProblems);
  print(problem.sums);
}
