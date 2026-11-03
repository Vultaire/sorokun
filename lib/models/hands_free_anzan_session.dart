import 'dart:math';

import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/divmult_set.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';

/// One generated, read-only problem for a hands-free Anzan session.
class HandsFreeAnzanProblem {
  const HandsFreeAnzanProblem({
    required this.subject,
    required this.level,
    required this.formattedProblem,
    required this.formattedAnswer,
  });

  final HandsFreeAnzanSubject subject;
  final PaperProblemLevel level;
  final Object formattedProblem;
  final String formattedAnswer;

  Duration solveDuration(int speedPercent) =>
      handsFreeProblemDuration(level, speedPercent: speedPercent.toDouble());
}

/// Supplies an endless stream of generated problems for the selected subjects.
///
/// In mixed mode, each shuffled cycle contains every selected subject exactly
/// once. Per-subject generated sets are refilled as they run out.
class HandsFreeAnzanProblemQueue {
  HandsFreeAnzanProblemQueue(this.config, {Random? random})
    : _random = random ?? Random() {
    _subjects = config.selectedSubjects.toList()..shuffle(_random);
    _refillRotation();
  }

  final HandsFreeAnzanSetupConfig config;
  final Random _random;
  late final List<HandsFreeAnzanSubject> _subjects;
  final Map<HandsFreeAnzanSubject, List<HandsFreeAnzanProblem>> _sets = {};
  final Map<HandsFreeAnzanSubject, int> _setIndices = {};
  List<HandsFreeAnzanSubject> _rotation = [];
  int _rotationIndex = 0;

  HandsFreeAnzanSubject? _lastRotationSubject;

  HandsFreeAnzanProblem next() {
    if (_rotationIndex >= _rotation.length) _refillRotation();
    final subject = _rotation[_rotationIndex++];
    final level = config.selectedLevels[subject]!;
    var problems = _sets[subject];
    var index = _setIndices[subject] ?? 0;

    if (problems == null || index >= problems.length) {
      problems = _generateSet(subject, level);
      if (problems.isEmpty) {
        throw StateError('No problems were generated for ${subject.name}.');
      }
      _sets[subject] = problems;
      index = 0;
    }

    _setIndices[subject] = index + 1;
    _lastRotationSubject = subject;
    return problems[index];
  }

  void _refillRotation() {
    _rotation = List.of(_subjects)..shuffle(_random);
    final last = _lastRotationSubject;
    if (_rotation.length > 1 && _rotation.first == last) {
      final replacementIndex = _rotation.indexWhere(
        (subject) => subject != last,
      );
      final first = _rotation[0];
      _rotation[0] = _rotation[replacementIndex];
      _rotation[replacementIndex] = first;
    }
    _rotationIndex = 0;
  }

  List<HandsFreeAnzanProblem> _generateSet(
    HandsFreeAnzanSubject subject,
    PaperProblemLevel level,
  ) => switch (subject) {
    HandsFreeAnzanSubject.mitori => _generateMitoriSet(level as MitoriLevel),
    HandsFreeAnzanSubject.multiplication || HandsFreeAnzanSubject.division =>
      _generateDivMultSet(level as DivMultLevel, subject),
  };

  List<HandsFreeAnzanProblem> _generateMitoriSet(MitoriLevel level) {
    final set = MitoriProblemSet(level: level);
    final problems = set.formattedProblems;
    final answers = set.formattedAnswers;
    return List.generate(
      problems.length,
      (index) => HandsFreeAnzanProblem(
        subject: HandsFreeAnzanSubject.mitori,
        level: level,
        formattedProblem: problems[index],
        formattedAnswer: answers[index],
      ),
    );
  }

  List<HandsFreeAnzanProblem> _generateDivMultSet(
    DivMultLevel level,
    HandsFreeAnzanSubject subject,
  ) {
    final set = DivMultProblemSet(level: level);
    final problems = set.formattedProblems;
    final answers = set.formattedAnswers;
    return List.generate(
      problems.length,
      (index) => HandsFreeAnzanProblem(
        subject: subject,
        level: level,
        formattedProblem: problems[index],
        formattedAnswer: answers[index],
      ),
    );
  }
}
