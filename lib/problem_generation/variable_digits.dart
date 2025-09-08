import 'dart:math';
import 'generation_spec.dart';

class VariableDigitsProblemSet {
  final PaperSpec spec;
  late List<List<int>> allProblems = [];
  late List<int> sums = [];

  VariableDigitsProblemSet({required this.spec}) {
    final rand = Random();

    int randomInt(int digits) {
      int min = pow(10, digits - 1).toInt();
      int max = pow(10, digits).toInt() - 1;
      return min + rand.nextInt(max - min + 1);
    }

    final problemSpec = spec.problemSpec;

    for (int i = 0; i < problemSpec.length; i++) {
      final entry = problemSpec[i];

      if (!entry.containsKey("template")) continue;

      final templateLists = entry["template"] as List;

      // Look for per-group settings in the next entries
      int repeatCount = 1;
      bool neverNegative = false;
      int minusCount = 0;
      int minusPerGroup = 2;

      List<int> templateCounts = [];

      for (int j = i + 1; j < problemSpec.length; j++) {
        final next = problemSpec[j];
        if (next.containsKey("repeat")) repeatCount = next["repeat"];
        if (next.containsKey("neverNegative"))
          neverNegative = next["neverNegative"];
        if (next.containsKey("minusCount")) minusCount = next["minusCount"];
        if (next.containsKey("minusPerGroup"))
          minusPerGroup = next["minusPerGroup"];
        if (next.containsKey("templateCountPerGroup")) {
          templateCounts = List<int>.from(
            next["templateCountPerGroup"] as List,
          );
        }
      }

      // Repeat the group (all template groups together)
      for (int r = 0; r < repeatCount; r++) {
        List<List<int>> groupProblems = [];

        for (var tgIndex = 0; tgIndex < templateLists.length; tgIndex++) {
          var templateGroup = templateLists[tgIndex];
          if (templateGroup is! List) continue;

          final templates = List<Map<String, int>>.from(templateGroup);

          // Determine number of problems for this template group
          int problemsInGroup = templateCounts.isNotEmpty
              ? templateCounts[tgIndex]
              : 1; // fallback if templateCounts not set

          for (int p = 0; p < problemsInGroup; p++) {
            List<int> problem = [];
            Set<int> usedNumbers = {};

            for (var template in templates) {
              final digits = template["digits"]!;
              final count = template["count"]!;
              int attempts = 0;

              for (int n = 0; n < count; n++) {
                int num;
                do {
                  num = randomInt(digits);
                  attempts++;
                  if (attempts > 1000) break;
                } while (usedNumbers.contains(num));

                problem.add(num);
                usedNumbers.add(num);
              }
            }

            problem.shuffle();
            groupProblems.add(problem);
          }
        }

        // Apply minuses to randomly chosen problems in the group
        if (minusPerGroup > 0 && minusCount > 0) {
          var problemIndices = List.generate(groupProblems.length, (i) => i)
            ..shuffle(rand);
          var selectedProblems = problemIndices.take(minusPerGroup);

          for (var idx in selectedProblems) {
            List<int> problem = groupProblems[idx];
            var minusIndices = List.generate(problem.length - 1, (i) => i + 1)
              ..shuffle(rand);

            int attempts = 0;
            const maxAttempts = 100;
            bool valid = false;

            while (!valid && attempts < maxAttempts) {
              attempts++;
              problem = problem.map((x) => x.abs()).toList();
              for (int k = 0; k < minusCount && k < problem.length; k++) {
                problem[minusIndices[k]] = -problem[minusIndices[k]].abs();
              }

              if (neverNegative) {
                int runningSum = 0;
                valid = true;
                for (var n in problem) {
                  runningSum += n;
                  if (runningSum < 0) {
                    valid = false;
                    minusIndices.shuffle(rand);
                    break;
                  }
                }
              } else {
                valid = true;
              }
            }

            if (!valid) {
              problem = problem.map((x) => x.abs()).toList();
            }

            groupProblems[idx] = problem;
          }
        }

        for (var problem in groupProblems) {
          allProblems.add(problem);
          sums.add(problem.reduce((a, b) => a + b));
        }
      }
    }
  }
}

void main() {
  var problem = VariableDigitsProblemSet(spec: getPaperSpec("1kyuu"));

  print(problem.allProblems);
  print(problem.sums);
}
