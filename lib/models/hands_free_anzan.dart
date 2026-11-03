import 'package:soroban_app/models/level_definitions.dart';

/// Calculates the exam time available per problem for a paper level.
Duration examAverageTimePerProblem(PaperProblemLevel level) {
  final problemCount = level.problemCount;
  if (problemCount <= 0) {
    throw ArgumentError.value(
      problemCount,
      'level.problemCount',
      'Must be positive',
    );
  }

  final examTimeLimit = level.levelInfo.timeLimit;
  if (examTimeLimit <= Duration.zero) {
    throw ArgumentError.value(
      examTimeLimit,
      'level.levelInfo.timeLimit',
      'Must be positive',
    );
  }

  return Duration(
    microseconds: (examTimeLimit.inMicroseconds / problemCount).round(),
  );
}

/// Calculates the display/solve interval for one problem at [speedPercent].
///
/// This interval does not include any pause used to display the answer.
Duration handsFreeProblemDuration(
  PaperProblemLevel level, {
  required double speedPercent,
}) {
  if (!speedPercent.isFinite || speedPercent <= 0) {
    throw ArgumentError.value(
      speedPercent,
      'speedPercent',
      'Must be positive and finite',
    );
  }

  final baselineMicroseconds = examAverageTimePerProblem(level).inMicroseconds;
  return Duration(
    microseconds: (baselineMicroseconds * 100 / speedPercent).round(),
  );
}

enum HandsFreeAnzanSubject { mitori, multiplication, division }

/// Returns the Anzan subjects supported by [kyuui], omitting unavailable ones.
Map<HandsFreeAnzanSubject, PaperProblemLevel> handsFreeAnzanSubjectsFor(
  Kyuui kyuui,
) {
  final subjects = <HandsFreeAnzanSubject, PaperProblemLevel>{};
  final mitori = kyuui.mitoriAnzan;
  final multiplication = kyuui.multAnzan;
  final division = kyuui.divAnzan;

  if (mitori != null) subjects[HandsFreeAnzanSubject.mitori] = mitori;
  if (multiplication != null) {
    subjects[HandsFreeAnzanSubject.multiplication] = multiplication;
  }
  if (division != null) subjects[HandsFreeAnzanSubject.division] = division;

  return Map.unmodifiable(subjects);
}
