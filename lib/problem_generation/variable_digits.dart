import 'dart:math';
import 'generation_spec.dart';
import 'paper_source.dart';

dynamic getEntryValue(List<Map<String, dynamic>> spec, String key) {
  final entry = spec.firstWhere((e) => e.containsKey(key), orElse: () => {});
  return entry[key];
}

class VariableDigitsProblem {
  final PaperSpec spec;
  late List<List<int>> allProblems = [];
  late List<int> sums = [];

  VariableDigitsProblem({required this.spec}) {
    final rand = Random();

    final templates =
        getEntryValue(spec.problemSpec, "template") as List<Map<String, int>>?;

    final minusCount = getEntryValue(spec.problemSpec, "minusCount") as int?;

    final templateCounts =
        getEntryValue(spec.problemSpec, "templateCountPerGroup") as List<int>?;

    int randomInt(int digits) {
      int min = pow(10, digits - 1).toInt();
      int max = pow(10, digits).toInt() - 1;

      return min + rand.nextInt(max - min + 1);
    }

    /*
    for (int i = 0; i < (spec.problemSpec['templateCountPerGroup'] ?? 20); i++) {
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
    */
  }
}

void main() {
  var problem = VariableDigitsProblem(spec: getPaperSpec("1kyuu"));

  print(problem.allProblems);
  print(problem.sums);
}
