import 'dart:math';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'mitori.dart';

sealed class MitoriProblemSet {
  MitoriProblemSet._();
  late final List<MitoriProblem> unformattedProblems = [];

  factory MitoriProblemSet({required MitoriLevel level}) {
    print('factory called with $level ${level.runtimeType}');
    return switch (level) {
      final SimpleMitoriLevel l => SimpleMitoriProblemSet(level: l),
      final ComplexMitoriLevel l => ComplexMitoriProblemSet(level: l),
    };
  }

  List<List<String>> get formattedProblems =>
      unformattedProblems.map((i) => i.formattedProblem).toList();
  List<String> get formattedAnswers =>
      unformattedProblems.map((i) => i.formattedAnswer).toList();
}

class ComplexMitoriProblemSet extends MitoriProblemSet {
  final ComplexMitoriLevel level;

  ComplexMitoriProblemSet({required this.level}) : super._() {
    final rand = Random();

    for (int r = 0; r < level.repeat; r++) {
      unformattedProblems.addAll(
        _generateGroupProblems(level: level, rand: rand),
      );
    }

    if (level.levelInfo.denomination == .nisshou && level.minusCount > 0) {
      applyNisshouMinus(
        fullProblemSet: unformattedProblems,
        minusCount: level.minusCount,
        rand: rand,
      );
    }
  }
}

List<MitoriProblem> _generateGroupProblems({
  required ComplexMitoriLevel level,
  required Random rand,
}) {
  final templateLists = level.templates as List;
  final groupProblems = <MitoriProblem>[];

  for (int groupIdx = 0; groupIdx < templateLists.length; groupIdx++) {
    final templateGroup = templateLists[groupIdx];
    if (templateGroup is! List) continue;

    final templates = List<Map<String, int>>.from(templateGroup);
    final problemsPerTemplate = level.problemCountPerTemplate[groupIdx];
    final templateProblems = _generateTemplateProblems(
      templates: templates,
      count: problemsPerTemplate,
      rand: rand,
    );

    if (level.levelInfo.denomination == .zenshuren && level.minusCount > 0) {
      final minusCount =
          level.minusCountPerGroup?[groupIdx] ?? level.minusCount;
      final bool isNeverNegative = level.neverNegative!;
      final int minusProblemsPerTemplate = level.minusProblemsPerTemplate!;
      applyZenshurenMinus(
        templateProblems: templateProblems,
        isNeverNegative: isNeverNegative,
        minusProblemsPerTemplate: minusProblemsPerTemplate,
        problemsPerTemplate: problemsPerTemplate,
        minusCount: minusCount,
        rand: rand,
      );
    }

    groupProblems.addAll(templateProblems);
  }

  return groupProblems;
}

List<MitoriProblem> _generateTemplateProblems({
  required List<Map<String, int>> templates,
  required int count,
  required Random rand,
}) {
  final problems = <MitoriProblem>[];
  for (int p = 0; p < count; p++) {
    final randomLayout = <int>[];
    for (final template in templates) {
      for (int n = 0; n < template["count"]!; n++) {
        randomLayout.add(template["digits"]!);
      }
    }
    randomLayout.shuffle();
    final problem = generateMitoriProblemFromDigitList(randomLayout, rand);
    problems.add(MitoriProblem(problem));
  }
  return problems;
}

class SimpleMitoriProblemSet extends MitoriProblemSet {
  final SimpleMitoriLevel level;

  SimpleMitoriProblemSet({required this.level}) : super._() {
    Random rand = Random();

    switch (level) {
      case .zsak10:
        for (var i = 0; i < 5; i++) {
          List<int> numbers = noCarry(.zsk18, rand);
          MitoriProblem problem = MitoriProblem(numbers);
          unformattedProblems.add(problem);
        }
        for (var i = 0; i < 5; i++) {
          List<int> numbers = noCarry(.zsk17, rand);
          MitoriProblem problem = MitoriProblem(numbers);
          unformattedProblems.add(problem);
        }
      case .zsak9:
        for (var i = 0; i < 10; i++) {
          List<int> numbers = generateMitoriProblemFromDigitList([
            1,
            1,
            1,
            1,
          ], rand);
          MitoriProblem problem = MitoriProblem(numbers);
          unformattedProblems.add(problem);
        }
      case .zsak8:
        for (var i = 0; i < 5; i++) {
          List<int> numbers = generateMitoriProblemFromDigitList([
            1,
            1,
            1,
            1,
          ], rand);
          MitoriProblem problem = MitoriProblem(numbers);
          unformattedProblems.add(problem);
        }
        for (var i = 0; i < 5; i++) {
          List<int> numbers = generateMitoriProblemFromDigitList([
            2,
            1,
            1,
          ], rand);
          MitoriProblem problem = MitoriProblem(numbers);
          unformattedProblems.add(problem);
        }
    }
  }
}

void applyNisshouMinus({
  required List<MitoriProblem> fullProblemSet,
  required int minusCount,
  required Random rand,
}) {
  const List<int> minusProblems = [
    2,
    4,
    6,
    8,
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    26,
    28,
  ];
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
  final int numberCount = fullProblemSet[0].problem.length;

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

    if (problemNumber >= fullProblemSet.length) {
      break;
    }

    while (!foundValid && attempts < maxAttempts) {
      attempts++;

      // Shuffle for each attempt
      List<List<int>> shuffledLayouts = List.from(possibleLayouts)
        ..shuffle(rand);

      for (List<int> layout in shuffledLayouts) {
        List<int> result = List.from(fullProblemSet[problemNumber].problem);

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
          fullProblemSet[problemNumber].newProblem = result;
          foundValid = true;
          break;
        }
      }

      if (!foundValid) {
        // Shuffle if no valid minus configuration found, should be rare and mostly occur on nsk9
        fullProblemSet[problemNumber].problem.shuffle();
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
  required List<MitoriProblem> templateProblems,
  required bool isNeverNegative,
  required int minusProblemsPerTemplate,
  required int problemsPerTemplate,
  required int minusCount,
  required Random rand,
}) {
  List<int> indices = List.generate(problemsPerTemplate, (i) => i)
    ..shuffle(rand);
  Iterable<int> selectedIndices = indices.take(minusProblemsPerTemplate);

  for (var relativeIdx in selectedIndices) {
    int actualIdx = templateProblems.length - problemsPerTemplate + relativeIdx;
    List<int> problem = templateProblems[actualIdx].problem;

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

      if (isNeverNegative) {
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

    templateProblems[actualIdx].newProblem = problem;
  }
}

void main() {
  var problem = MitoriProblemSet(level: ComplexMitoriLevel.zsadan);

  print(problem.formattedProblems);
  print(problem.formattedAnswers);
}
