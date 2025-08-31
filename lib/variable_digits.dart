import 'dart:math';

class VariableDigitsProblem {
  final List<Map<String, int>> problemSpec;
  final bool includeMinus;
  final bool neverNegative;
  late List<int> problem = [];
  late int sum;

  VariableDigitsProblem({
    required this.problemSpec,
    this.includeMinus = true,
    this.neverNegative = true,
  }) {
    final rand = Random();

    int randomInt(int digits) {
      int min = pow(10, digits - 1).toInt();
      int max = pow(10, digits).toInt() - 1;

      return min + rand.nextInt(max - min + 1);
    }

    problem = [];

    for (var spec in problemSpec) {
      if (spec.containsKey('digits')) {
        int digits = spec['digits']!;
        int count = spec['count']!;
        for (int i = 0; i < count; i++) {
          problem.add(randomInt(digits));
        }
      } else if (spec.containsKey('minusCount')) {
        int minusCount = spec['minusCount']!;
        var minusIndices = List.generate(problem.length, (i) => i)
          ..shuffle(rand);
        if (neverNegative) {
          bool ok = false;

          while (!ok) {
            // Shuffle the problem
            problem.shuffle(rand);

            // Reset problem to all positive first
            problem = problem.map((x) => x.abs()).toList();

            // Apply negation to selected indices
            for (var i in minusIndices.take(minusCount)) {
              problem[i] = -problem[i].abs();
            }

            // Check running sum
            int runningSum = 0;
            ok = true; // assume it's okay
            for (var n in problem) {
              runningSum += n;
              if (runningSum < 0) {
                ok = false; // sum went negative, retry
                // Pick new random indices for negation
                minusIndices = List.generate(problem.length, (i) => i)
                  ..shuffle(rand);
                break; // exit the for loop and retry
              }
            }
          }
        }
      }
    }

    if (includeMinus) {}
  }
}

void main() {
  var problem = VariableDigitsProblem(
    problemSpec: [
      {'digits': 3, 'count': 3},
      {'digits': 4, 'count': 2},
      {'digits': 5, 'count': 2},
      {'digits': 6, 'count': 3},
      {'minusCount': 3},
    ],
  );

  print(problem.problem);
}
