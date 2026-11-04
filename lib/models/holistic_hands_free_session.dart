import 'dart:math';

import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/divmult_set.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';

/// The display data for one generated problem. Answers are kept separately from
/// prompts so the runner can reveal them only in its answer phase.
class HolisticHandsFreeGeneratedProblem {
  const HolisticHandsFreeGeneratedProblem({
    required this.formattedPrompt,
    required this.formattedAnswer,
    this.flashNumbers,
  });

  final Object formattedPrompt;
  final String formattedAnswer;

  /// Present for Flash Anzan; each value is one number in the stream.
  final List<String>? flashNumbers;
}

/// Generates one full underlying problem set for a playlist occurrence.
///
/// The random source is shared with the queue so tests can inject deterministic
/// generators without replacing the queue's balancing behavior.
typedef HolisticHandsFreeProblemSetGenerator =
    List<HolisticHandsFreeGeneratedProblem> Function(
      HolisticPracticePlaylistEntry entry,
      Random random,
    );

/// One generated problem tied to its playlist occurrence. Duplicate entries
/// retain distinct [playlistIndex] values and therefore independent weights.
class HolisticHandsFreeProblem {
  const HolisticHandsFreeProblem({
    required this.entry,
    required this.playlistIndex,
    required this.formattedPrompt,
    required this.formattedAnswer,
    this.flashNumbers,
  });

  final HolisticPracticePlaylistEntry entry;
  final int playlistIndex;
  final Object formattedPrompt;
  final String formattedAnswer;
  final List<String>? flashNumbers;

  bool get isFlash => entry is FlashAnzanPlaylistEntry;
}

/// Supplies an endless shuffled, balanced bag of playlist occurrences.
///
/// Every cycle contains each playlist index exactly once. Each occurrence has
/// its own generated set and gets a fresh set when that set is exhausted.
class HolisticHandsFreeProblemQueue {
  HolisticHandsFreeProblemQueue(
    this.config, {
    Random? random,
    HolisticHandsFreeProblemSetGenerator? problemSetGenerator,
  }) : _random = random ?? Random(),
       _problemSetGenerator =
           problemSetGenerator ?? generateHolisticHandsFreeProblemSet {
    if (config.playlist.isEmpty) {
      throw ArgumentError.value(
        config.playlist,
        'playlist',
        'Must not be empty',
      );
    }
    _shuffleBag();
  }

  final HolisticHandsFreePracticeConfig config;
  final Random _random;
  final HolisticHandsFreeProblemSetGenerator _problemSetGenerator;
  final Map<int, List<HolisticHandsFreeGeneratedProblem>> _sets = {};
  final Map<int, int> _setIndices = {};
  List<int> _bag = [];
  int _bagIndex = 0;

  HolisticHandsFreeProblem next() {
    if (_bagIndex >= _bag.length) _shuffleBag();
    final playlistIndex = _bag[_bagIndex++];
    final entry = config.playlist[playlistIndex];
    var problems = _sets[playlistIndex];
    var setIndex = _setIndices[playlistIndex] ?? 0;

    if (problems == null || setIndex >= problems.length) {
      problems = _problemSetGenerator(entry, _random);
      if (problems.isEmpty) {
        throw StateError(
          'No problems were generated for playlist item ${playlistIndex + 1}.',
        );
      }
      _sets[playlistIndex] = List.unmodifiable(problems);
      setIndex = 0;
    }

    _setIndices[playlistIndex] = setIndex + 1;
    final problem = problems[setIndex];
    return HolisticHandsFreeProblem(
      entry: entry,
      playlistIndex: playlistIndex,
      formattedPrompt: problem.formattedPrompt,
      formattedAnswer: problem.formattedAnswer,
      flashNumbers: problem.flashNumbers == null
          ? null
          : List.unmodifiable(problem.flashNumbers!),
    );
  }

  void _shuffleBag() {
    _bag = List<int>.generate(config.playlist.length, (index) => index)
      ..shuffle(_random);
    _bagIndex = 0;
  }
}

/// Builds one full set using the application's existing level generators.
List<HolisticHandsFreeGeneratedProblem> generateHolisticHandsFreeProblemSet(
  HolisticPracticePlaylistEntry entry,
  Random random,
) {
  if (entry is PaperAnzanPlaylistEntry) {
    return switch (entry.activity) {
      HolisticPracticeActivity.mitoriAnzan => _generateMitori(entry, random),
      HolisticPracticeActivity.multiplicationAnzan ||
      HolisticPracticeActivity.divisionAnzan => _generateDivMult(entry, random),
      HolisticPracticeActivity.flashAnzan => throw StateError(
        'Flash Anzan must use a flash playlist entry.',
      ),
    };
  }

  final flashEntry = entry as FlashAnzanPlaylistEntry;
  final set = FlashProblemSet(flashEntry.level, random: random);
  final problems = set.formattedProblems;
  final answers = set.formattedAnswers;
  return List.generate(
    problems.length,
    (index) => HolisticHandsFreeGeneratedProblem(
      formattedPrompt: problems[index],
      flashNumbers: problems[index],
      formattedAnswer: answers[index],
    ),
  );
}

List<HolisticHandsFreeGeneratedProblem> _generateMitori(
  PaperAnzanPlaylistEntry entry,
  Random random,
) {
  final level = entry.level as MitoriLevel;
  final set = MitoriProblemSet(level: level, random: random);
  final problems = set.formattedProblems;
  final answers = set.formattedAnswers;
  return List.generate(
    problems.length,
    (index) => HolisticHandsFreeGeneratedProblem(
      formattedPrompt: problems[index],
      formattedAnswer: answers[index],
    ),
  );
}

List<HolisticHandsFreeGeneratedProblem> _generateDivMult(
  PaperAnzanPlaylistEntry entry,
  Random random,
) {
  final level = entry.level as DivMultLevel;
  final set = DivMultProblemSet(level: level, random: random);
  return [
    for (final problem in set.fullProblemSet)
      HolisticHandsFreeGeneratedProblem(
        // DivMultProblem.toString() includes the answer, so use .problem only.
        formattedPrompt: problem.problem,
        formattedAnswer: problem.formattedThird,
      ),
  ];
}
