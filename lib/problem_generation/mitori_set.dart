import 'dart:math';
import 'package:soroban_app/models/level_definitions.dart';
import 'mitori.dart';

import 'helpers.dart';

class MitoriProblemSet {
  final MitoriLevel level;
  late List<List<int>> allProblems = [];
  late List<List<String>> formattedProblems = [];
  late List<int> sums = [];
  late List<String> formattedAnswers = [];

  MitoriProblemSet({required this.level}) {
    final rand = Random();

    final templateLists = level.templates as List;
    final int repeat = level.repeat;
    final int minusCount = level.minusCount;
    final List<int> templateCounts = level.templateCountPerGroup;

    // Repeat the group (all template groups together)
    for (int r = 0; r < repeat; r++) {
      List<List<int>> groupProblems = [];

      for (
        var templategroupIdx = 0;
        templategroupIdx < templateLists.length;
        templategroupIdx++
      ) {
        var templateGroup = templateLists[templategroupIdx];
        if (templateGroup is! List) continue;

        final templates = List<Map<String, int>>.from(templateGroup);

        // Determine number of problems for this template group
        int problemsInGroup = templateCounts[templategroupIdx];

        for (int p = 0; p < problemsInGroup; p++) {
          // Generate randomLayout list
          List<int> randomLayout = [];
          for (var template in templates) {
            final digits = template["digits"]!;
            final count = template["count"]!;
            for (int n = 0; n < count; n++) {
              randomLayout.add(digits);
            }
          }
          randomLayout.shuffle();

          // Generate problem using shuffled layout
          List<int> problem = generateMitoriProblemFromDigitList(
            randomLayout,
            rand,
          );

          groupProblems.add(problem);
        }

        // Apply minuses to specific problems in this template group
        if (minusCount > 0) {
          switch (level.denomination) {
            case .zenshuren:
              applyZenshurenMinus(
                groupProblems: groupProblems,
                level: level,
                problemsInGroup: problemsInGroup,
                minusCount: minusCount,
                rand: rand,
              );
            case .nisshou:
              applyNisshouMinus(
                level: level,
                groupProblems: groupProblems,
                minusCount: minusCount,
                rand: rand,
              );
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
    }
    for (int sum in sums) {
      String formattedSum = formatWithCommas(sum.toString());
      formattedAnswers.add(formattedSum);
    }
  }
}

void applyNisshouMinus({
  required MitoriLevel level,
  required List<List<int>> groupProblems,
  required int minusCount,
  required Random rand,
}) {
  const List<int> minusProblems = [2, 4, 6, 8];
  const Map<String, List<List<int>>> minusPositions = {
    '5-1': [
      [2],
      [3],
    ],
    '8-2': [
      [2, 3],
      [2, 4],
      [2, 5],
      [2, 6],
      [3, 4],
      [3, 5],
      [3, 6],
    ],
    '10-3': [
      [2, 3, 5],
      [2, 3, 6],
      [2, 3, 7],
      [2, 3, 8],
      [2, 4, 5],
      [2, 5, 6],
      [2, 6, 7],
      [2, 7, 8],
      [3, 4, 6],
      [3, 4, 7],
      [3, 4, 8],
      [3, 5, 6],
      [3, 6, 7],
      [3, 7, 8],
      [4, 5, 7],
      [4, 5, 8],
      [4, 6, 7],
      [4, 7, 8],
      [5, 6, 8],
      [5, 7, 8],
    ],
    '10-4': [
      [2, 3, 5, 6],
      [2, 3, 6, 7],
      [2, 3, 7, 8],
      [3, 4, 6, 7],
      [3, 4, 7, 8],
      [4, 5, 7, 8],
    ],
  };
  final int numberCount = groupProblems[0].length;

  final String key = '$numberCount-$minusCount';

  List<List<int>>? possibleLayouts = minusPositions[key];

  if (possibleLayouts == null) {
    throw ArgumentError(
      'Invalid combination: $numberCount elements with $minusCount minuses',
    );
  }

  for (int problemNumber in minusProblems) {
    bool foundValid = false;
    int maxAttempts = 100; // Adjust as needed
    int attempts = 0;

    while (!foundValid && attempts < maxAttempts) {
      attempts++;

      // Shuffle for each attempt
      List<List<int>> shuffledLayouts = List.from(possibleLayouts)
        ..shuffle(rand);

      for (List<int> layout in shuffledLayouts) {
        List<int> result = List.from(groupProblems[problemNumber]);

        // Apply negatives at the specified indices
        for (int index in layout) {
          result[index] = -result[index];
        }

        // Check if running sum is always positive
        int runningSum = 0;
        bool valid = true;
        for (int num in result) {
          runningSum += num;
          if (runningSum < 0) {
            valid = false;
            break;
          }
        }

        if (valid) {
          groupProblems[problemNumber] = result;
          foundValid = true;
          break;
        }
      }

      if (!foundValid) {
        // Shuffle if no valid minus configuration found, should be rare and mostly occur on nsk9
        groupProblems[problemNumber].shuffle();
      }
    }

    if (!foundValid) {
      throw Exception(
        'Could not find valid minus placement for problem $problemNumber after $maxAttempts attempts',
      );
    }
  }
}

void applyZenshurenMinus({
  required List<List<int>> groupProblems,
  required MitoriLevel level,
  required int problemsInGroup,
  required int minusCount,
  required Random rand,
}) {
  final bool neverNegative = level.neverNegative!;
  final int minusProblemsPerGroup = level.minusProblemsPerGroup!;
  List<int> indices = List.generate(problemsInGroup, (i) => i)..shuffle(rand);
  Iterable<int> selectedIndices = indices.take(minusProblemsPerGroup);

  for (var relativeIdx in selectedIndices) {
    int actualIdx = groupProblems.length - problemsInGroup + relativeIdx;
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
            problem.shuffle(rand);
            break;
          }
        }
      } else {
        valid = true;
      }
    }

    if (!valid) {
      throw Exception(
        'maxAttempts at minus application exceeded.',
      ); //TODO: Remove this.
    }

    groupProblems[actualIdx] = problem;
  }
}

void main() {
  var problem = MitoriProblemSet(level: MitoriLevel.nsk1);

  print(problem.formattedProblems);
  print(problem.formattedAnswers);
}
