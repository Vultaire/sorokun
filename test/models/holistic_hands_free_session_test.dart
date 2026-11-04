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
    test(
      'each shuffled cycle contains every duplicate playlist occurrence',
      () {
        final config = HolisticHandsFreePracticeConfig(
          playlist: [mitori, mitori, flash],
        );
        final queue = HolisticHandsFreeProblemQueue(
          config,
          random: Random(42),
          problemSetGenerator: (_, random) => [
            HolisticHandsFreeGeneratedProblem(
              formattedPrompt: random.nextInt(1000).toString(),
              formattedAnswer: 'answer',
            ),
            HolisticHandsFreeGeneratedProblem(
              formattedPrompt: random.nextInt(1000).toString(),
              formattedAnswer: 'answer',
            ),
          ],
        );

        for (var cycle = 0; cycle < 5; cycle++) {
          final indices = [
            for (var index = 0; index < config.playlist.length; index++)
              queue.next().playlistIndex,
          ]..sort();
          expect(indices, [0, 1, 2]);
        }
      },
    );

    test('regenerates each occurrence set independently when exhausted', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [mitori, mitori, flash],
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
