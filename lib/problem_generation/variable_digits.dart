import 'dart:math';
import 'generation_spec.dart';
import 'helpers.dart';

class VariableDigitsProblemSet {
  final PaperSpec spec;
  late List<List<int>> allProblems = [];
  late List<List<String>> formattedProblems = [];
  late List<int> sums = [];
  late List<String> formattedSums = [];

  VariableDigitsProblemSet({required this.spec}) {
    final rand = Random();

    final source = spec.source;

    for (int i = 0; i < source.length; i++) {
      final entry = source[i];

      if (!entry.containsKey("templates")) continue;

      final templateLists = entry["templates"] as List;

      // Look for per-group settings in the next entries
      int repeatCount = 1;
      bool neverNegative = false;
      int minusCount = 0;
      int minusPerGroup = 2;

      List<int> templateCounts = [];

      for (int j = i + 1; j < source.length; j++) {
        final next = source[j];
        if (next.containsKey("repeat")) {
          repeatCount = next["repeat"];
        }
        if (next.containsKey("neverNegative")) {
          neverNegative = next["neverNegative"];
        }
        if (next.containsKey("minusCount")) {
          minusCount = next["minusCount"];
        }
        if (next.containsKey("minusPerGroup")) {
          minusPerGroup = next["minusPerGroup"];
        }
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

            // Generate randomLayout list
            List<int> randomLayout = [];
            for (var template in templates) {
              final digits = template["digits"]!;
              final count = template["count"]!;
              for (int n = 0; n < count; n++) {
                randomLayout.add(digits);
              }
            }

            // Shuffle the layout
            randomLayout.shuffle();

            // Generate problem using shuffled layout
            for (int digits in randomLayout) {
              int? lastNum = problem.isNotEmpty ? problem.last : null;
              int number = getRandomInt(
                digits,
                spec.digitAllDifferent,
                lastNum,
              );
              problem.add(number);
            }

            groupProblems.add(problem);
          }

          // Apply minuses to specific problems in this template group
          // Select problems randomly within this group
          if (minusPerGroup > 0 && minusCount > 0) {
            var indices = List.generate(problemsInGroup, (i) => i)
              ..shuffle(rand);
            var selectedIndices = indices.take(minusPerGroup);

            for (var relativeIdx in selectedIndices) {
              int actualIdx =
                  groupProblems.length - problemsInGroup + relativeIdx;
              List<int> problem = groupProblems[actualIdx];

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

              groupProblems[actualIdx] = problem;
            }
          }
        }

        // Add all problems from this group to the final lists
        for (var problem in groupProblems) {
          allProblems.add(problem);
          List<String> formattedProblem = [];
          for (int number in problem) {
            String formattedNumber = formatWithCommas(number.toString());
            formattedProblem.add(formattedNumber);
          }
          formattedProblems.add(formattedProblem);
          sums.add(problem.reduce((a, b) => a + b));
        }
        for (int sum in sums) {
          String formattedSum = formatWithCommas(sum.toString());
          formattedSums.add(formattedSum);
        }
      }
    }
  }
}

void main() {
  var problem = VariableDigitsProblemSet(spec: getPaperSpec("dan"));

  print(problem.formattedProblems);
  print(problem.formattedSums);
}
