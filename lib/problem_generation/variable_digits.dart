import 'dart:math';
import 'generation_spec.dart';
import 'paper_source.dart';

class VariableDigitsProblem {
  final PaperSpec spec;
  late List<List<int>> allProblems = [];
  late List<int> sums = [];

  VariableDigitsProblem({required this.spec}) {
    final rand = Random();

    int randomInt(int digits) {
      int min = pow(10, digits - 1).toInt();
      int max = pow(10, digits).toInt() - 1;
      return min + rand.nextInt(max - min + 1);
    }

    final problemSpec = spec.problemSpec ?? [];

    for (int i = 0; i < problemSpec.length; i++) {
      final entry = problemSpec[i];

      // Only process entries with "template"
      if (!entry.containsKey("template")) continue;

      final templates = List<Map<String, int>>.from(entry["template"] as List);

      // Look ahead to merge related keys
      int repeatCount = 1;
      bool neverNegative = true;
      List<int> templateCounts = List.filled(templates.length, 1);
      int minusCount = 0;
      int minusPerGroup = 2;

      for (int j = i + 1; j < problemSpec.length; j++) {
        final next = problemSpec[j];
        if (next.containsKey("repeat")) repeatCount = next["repeat"];
        if (next.containsKey("neverNegative")) {
          neverNegative = next["neverNegative"];
        }
        if (next.containsKey("templateCountPerGroup")) {
          templateCounts = List<int>.from(
            next["templateCountPerGroup"] as List,
          );
        }
        if (next.containsKey("minusCount")) minusCount = next["minusCount"];
      }

      // Repeat the group as specified
      for (int r = 0; r < repeatCount; r++) {
        for (int p = 0; p < templateCounts.first; p++) {
          List<int> problem = [];

          for (var template in templates) {
            final digits = template["digits"]!;
            final count = template["count"]!;
            for (int n = 0; n < count; n++) {
              problem.add(randomInt(digits));
            }
          }

          if (minusCount > 0 && problem.length >= minusCount) {
            var indices = List.generate(problem.length, (index) => index)
              ..shuffle(rand);

            if (neverNegative) {
              bool ok = false;

              while (!ok) {
                problem.shuffle(rand);
                problem = problem.map((x) => x.abs()).toList();

                for (var i in indices.take(minusCount)) {
                  problem[i] = -problem[i].abs();
                }

                int runningSum = 0;
                ok = true;
                for (var n in problem) {
                  runningSum += n;
                  if (runningSum < 0) {
                    ok = false;
                    indices = List.generate(problem.length, (i) => i)
                      ..shuffle(rand);
                    break;
                  }
                }
              }
            } else {
              for (var i in indices.take(minusCount)) {
                problem[i] = -problem[i].abs();
              }
            }
            for (int k = 0; k < minusCount; k++) {
              problem[indices[k]] = -problem[indices[k]].abs();
            }
          }

          allProblems.add(problem);
          sums.add(problem.reduce((a, b) => a + b));
        }
      }
    }
  }
}

void main() {
  var problem = VariableDigitsProblem(spec: getPaperSpec("10kyuuB"));

  print(problem.allProblems);
  print(problem.sums);
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
