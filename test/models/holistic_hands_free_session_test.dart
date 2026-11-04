import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/holistic_hands_free_session.dart';
import 'package:soroban_app/models/level_definitions.dart';

void main() {
  final mitori = HolisticPracticePlaylistEntry.paperAnzan(
    activity: HolisticPracticeActivity.mitoriAnzan,
    denomination: Denomination.zenshuren,
    kyuui: Kyuui.zsk10,
  );
  final multiplication = HolisticPracticePlaylistEntry.paperAnzan(
    activity: HolisticPracticeActivity.multiplicationAnzan,
    denomination: Denomination.zenshuren,
    kyuui: Kyuui.zsk4,
  );
  final division = HolisticPracticePlaylistEntry.paperAnzan(
    activity: HolisticPracticeActivity.divisionAnzan,
    denomination: Denomination.zenshuren,
    kyuui: Kyuui.zsk3,
  );
  final flash = HolisticPracticePlaylistEntry.flashAnzan(
    denomination: Denomination.zenshuren,
    kyuui: Kyuui.zsk20,
  );

  group('holistic problem generation', () {
    test('uses MitoriProblemSet for Mitori Anzan', () {
      final generated = generateHolisticHandsFreeProblemSet(mitori, Random(10));

      expect(generated, isNotEmpty);
      expect(generated.first.formattedPrompt, isA<List<String>>());
      expect(generated.first.formattedAnswer, isNotEmpty);
    });

    test(
      'uses DivMultProblem.problem without its answer for multiplication',
      () {
        final generated = generateHolisticHandsFreeProblemSet(
          multiplication,
          Random(11),
        );

        expect(generated, isNotEmpty);
        expect(generated.first.formattedPrompt, isA<String>());
        expect(generated.first.formattedPrompt, isNot(contains('=')));
        expect(generated.first.formattedAnswer, isNotEmpty);
      },
    );

    test('uses DivMultProblem.problem without its answer for division', () {
      final generated = generateHolisticHandsFreeProblemSet(
        division,
        Random(12),
      );

      expect(generated, isNotEmpty);
      expect(generated.first.formattedPrompt, isA<String>());
      expect(generated.first.formattedPrompt, isNot(contains('=')));
      expect(generated.first.formattedAnswer, isNotEmpty);
    });

    test('Flash Anzan preserves the selected level number sequence', () {
      final generated = generateHolisticHandsFreeProblemSet(flash, Random(13));

      expect(generated, isNotEmpty);
      expect(generated.first.flashNumbers, hasLength(FlashLevel.zsk20.kuchi));
      expect(generated.first.formattedPrompt, generated.first.flashNumbers);
      expect(generated.first.formattedAnswer, isNotEmpty);
    });

    test('each generator is reproducible with its injected random source', () {
      for (final entry in [mitori, multiplication, division, flash]) {
        List<(String, String, String?)> generate() =>
            generateHolisticHandsFreeProblemSet(entry, Random(314159))
                .map(
                  (problem) => (
                    problem.formattedPrompt.toString(),
                    problem.formattedAnswer,
                    problem.flashNumbers?.toString(),
                  ),
                )
                .toList();

        expect(generate(), generate(), reason: entry.activity.name);
      }
    });
  });

  group('holistic endless queue', () {
    test('playlist order follows configured occurrences and wraps', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [mitori, multiplication, flash],
        selectionOrder: HolisticHandsFreeSelectionOrder.playlistOrder,
      );
      final queue = HolisticHandsFreeProblemQueue(
        config,
        random: _SequenceRandom(const []),
        problemSetGenerator: (_, _) => const [
          HolisticHandsFreeGeneratedProblem(
            formattedPrompt: 'prompt',
            formattedAnswer: 'answer',
          ),
        ],
      );

      expect(
        [for (var index = 0; index < 8; index++) queue.next().playlistIndex],
        [0, 1, 2, 0, 1, 2, 0, 1],
      );
    });

    test('random selection samples with replacement and allows repeats', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [mitori, multiplication],
      );
      final random = _SequenceRandom([1, 1, 0, 0]);
      final queue = HolisticHandsFreeProblemQueue(
        config,
        random: random,
        problemSetGenerator: (_, _) => const [
          HolisticHandsFreeGeneratedProblem(
            formattedPrompt: 'prompt',
            formattedAnswer: 'answer',
          ),
        ],
      );

      expect(
        [for (var index = 0; index < 4; index++) queue.next().playlistIndex],
        [1, 1, 0, 0],
      );
      expect(random.bounds, [2, 2, 2, 2]);
    });

    test('duplicate occurrences independently add random selection weight', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [mitori, mitori, flash],
      );
      final random = _SequenceRandom([0, 1, 2, 0, 1, 2]);
      final queue = HolisticHandsFreeProblemQueue(
        config,
        random: random,
        problemSetGenerator: (_, _) => const [
          HolisticHandsFreeGeneratedProblem(
            formattedPrompt: 'prompt',
            formattedAnswer: 'answer',
          ),
        ],
      );

      final selected = [for (var index = 0; index < 6; index++) queue.next()];
      expect(selected.map((problem) => problem.playlistIndex), [
        0,
        1,
        2,
        0,
        1,
        2,
      ]);
      expect(
        selected.where((problem) => problem.entry.activity == mitori.activity),
        hasLength(4),
      );
      expect(
        selected.where((problem) => problem.entry.activity == flash.activity),
        hasLength(2),
      );
      expect(random.bounds, [3, 3, 3, 3, 3, 3]);
    });

    test('regenerates each occurrence set independently when exhausted', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [mitori, mitori, flash],
        selectionOrder: HolisticHandsFreeSelectionOrder.playlistOrder,
      );
      var generatedSets = 0;
      final queue = HolisticHandsFreeProblemQueue(
        config,
        random: Random(23),
        problemSetGenerator: (_, _) {
          generatedSets++;
          return [
            const HolisticHandsFreeGeneratedProblem(
              formattedPrompt: 'one',
              formattedAnswer: 'one',
            ),
            const HolisticHandsFreeGeneratedProblem(
              formattedPrompt: 'two',
              formattedAnswer: 'two',
            ),
          ];
        },
      );

      for (var index = 0; index < config.playlist.length * 2; index++) {
        queue.next();
      }
      expect(generatedSets, config.playlist.length);

      for (var index = 0; index < config.playlist.length; index++) {
        queue.next();
      }
      expect(generatedSets, config.playlist.length * 2);
    });

    test('rejects an empty generated set instead of looping', () {
      final queue = HolisticHandsFreeProblemQueue(
        HolisticHandsFreePracticeConfig(playlist: [mitori]),
        random: Random(1),
        problemSetGenerator: (_, _) => const [],
      );

      expect(queue.next, throwsStateError);
    });
  });
}

class _SequenceRandom implements Random {
  _SequenceRandom(Iterable<int> values) : _values = values.iterator;

  final Iterator<int> _values;
  final List<int> bounds = [];

  @override
  int nextInt(int max) {
    bounds.add(max);
    if (!_values.moveNext()) throw StateError('No deterministic random value');
    return _values.current;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}
