import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';

void main() {
  group('holistic practice entry resolution', () {
    test('resolves Zenshuren 3-kyu Mitorizan', () {
      final entry = HolisticPracticePlaylistEntry.paperAnzan(
        activity: HolisticPracticeActivity.mitoriAnzan,
        denomination: Denomination.zenshuren,
        kyuui: Kyuui.zsk3,
      );

      expect(entry, isA<PaperAnzanPlaylistEntry>());
      expect(entry.activity, HolisticPracticeActivity.mitoriAnzan);
      expect(entry.level, ComplexMitoriLevel.zsak3);
    });

    test('resolves Zenshuren 3-kyu division Anzan', () {
      final entry = HolisticPracticePlaylistEntry.paperAnzan(
        activity: HolisticPracticeActivity.divisionAnzan,
        denomination: Denomination.zenshuren,
        kyuui: Kyuui.zsk3,
      );

      expect(entry.level, DivMultLevel.zsdak3);
    });

    test('resolves Zenshuren 4-kyu multiplication Anzan', () {
      final entry = HolisticPracticePlaylistEntry.paperAnzan(
        activity: HolisticPracticeActivity.multiplicationAnzan,
        denomination: Denomination.zenshuren,
        kyuui: Kyuui.zsk4,
      );

      expect(entry.level, DivMultLevel.zsmak4);
    });

    test('resolves Association flash grades 7 and 6 through kkFlash', () {
      final grade7 = HolisticPracticePlaylistEntry.flashAnzan(
        denomination: Denomination.kyoukai,
        kyuui: KyuuiDenomination.kkFlash.k7,
      );
      final grade6 = HolisticPracticePlaylistEntry.flashAnzan(
        denomination: Denomination.kyoukai,
        kyuui: KyuuiDenomination.kkFlash.k6,
      );

      expect(grade7.activity, HolisticPracticeActivity.flashAnzan);
      expect(grade7.level, FlashLevel.kkk7);
      expect(grade6.level, FlashLevel.kkk6);
    });

    test('resolves Zenshuren flash using the Kyuui flash level', () {
      final entry = HolisticPracticePlaylistEntry.flashAnzan(
        denomination: Denomination.zenshuren,
        kyuui: KyuuiDenomination.zsFlash.k3,
      );

      expect(entry.level, FlashLevel.zsk3);
    });

    test(
      'rejects unavailable or mismatched organization/level combinations',
      () {
        expect(
          () => HolisticPracticePlaylistEntry.paperAnzan(
            activity: HolisticPracticeActivity.divisionAnzan,
            denomination: Denomination.nisshou,
            kyuui: Kyuui.nsk10,
          ),
          throwsArgumentError,
        );
        expect(
          () => HolisticPracticePlaylistEntry.paperAnzan(
            activity: HolisticPracticeActivity.mitoriAnzan,
            denomination: Denomination.nisshou,
            kyuui: Kyuui.zsk3,
          ),
          throwsArgumentError,
        );
        expect(
          () => HolisticPracticePlaylistEntry.flashAnzan(
            denomination: Denomination.zenshuren,
            kyuui: KyuuiDenomination.kkFlash.k7,
          ),
          throwsArgumentError,
        );
        expect(
          () => HolisticPracticePlaylistEntry.paperAnzan(
            activity: HolisticPracticeActivity.flashAnzan,
            denomination: Denomination.zenshuren,
            kyuui: Kyuui.zsk3,
          ),
          throwsArgumentError,
        );
      },
    );
  });

  group('holistic practice timing', () {
    final paper = HolisticPracticePlaylistEntry.paperAnzan(
      activity: HolisticPracticeActivity.mitoriAnzan,
      denomination: Denomination.zenshuren,
      kyuui: Kyuui.zsk3,
    );

    test('reuses paper hands-free timing and exam baseline', () {
      final paperLevel = (paper as PaperAnzanPlaylistEntry).level;

      expect(examAverageTimePerProblem(paperLevel), const Duration(seconds: 9));
      expect(
        paper.displayedProblemDuration(speedPercent: 100),
        handsFreeProblemDuration(paperLevel, speedPercent: 100),
      );
      expect(
        paper.displayedProblemDuration(speedPercent: 50),
        handsFreeProblemDuration(paperLevel, speedPercent: 50),
      );
      expect(
        paper.displayedProblemDuration(speedPercent: 200),
        handsFreeProblemDuration(paperLevel, speedPercent: 200),
      );
    });

    test('scales Flash Anzan stream duration at 50, 100, and 200 percent', () {
      const level = FlashLevel.zsk20;

      expect(
        handsFreeFlashStreamDuration(level, speedPercent: 50),
        const Duration(seconds: 4),
      );
      expect(
        handsFreeFlashStreamDuration(level, speedPercent: 100),
        const Duration(seconds: 2),
      );
      expect(
        handsFreeFlashStreamDuration(level, speedPercent: 200),
        const Duration(seconds: 1),
      );
    });

    test(
      'keeps thinking delay and answer dwell independent of stream timing',
      () {
        final flash = HolisticPracticePlaylistEntry.flashAnzan(
          denomination: Denomination.kyoukai,
          kyuui: KyuuiDenomination.kkFlash.k7,
        );
        final config = HolisticHandsFreePracticeConfig(
          playlist: [flash],
          thinkingDelay: const Duration(seconds: 8),
          answerDisplayDwell: const Duration(seconds: 3),
        );

        expect(config.thinkingDelay, const Duration(seconds: 8));
        expect(config.answerDisplayDwell, const Duration(seconds: 3));
        expect(
          flash.displayedProblemDuration(speedPercent: config.speedPercent),
          const Duration(seconds: 8),
        );
      },
    );

    test('accepts boundary speeds and preserves duplicate entries', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [paper, paper],
        speedPercent: 50,
      );

      expect(config.speedPercent, 50);
      expect(config.playlist, [paper, paper]);
      expect(config.playlist, hasLength(2));
      expect(() => config.playlist.add(paper), throwsUnsupportedError);
      expect(
        HolisticHandsFreePracticeConfig(
          playlist: [paper],
          speedPercent: 200,
        ).speedPercent,
        200,
      );
    });

    test('defaults both independent answer phases to five seconds', () {
      final config = HolisticHandsFreePracticeConfig(playlist: [paper]);

      expect(
        config.selectionOrder,
        HolisticHandsFreeSelectionOrder.randomSelection,
      );
      expect(config.speedPercent, 100);
      expect(config.thinkingDelay, const Duration(seconds: 5));
      expect(config.answerDisplayDwell, const Duration(seconds: 5));
    });

    test('retains an explicit immutable selection order', () {
      final config = HolisticHandsFreePracticeConfig(
        playlist: [paper],
        selectionOrder: HolisticHandsFreeSelectionOrder.playlistOrder,
      );

      expect(
        config.selectionOrder,
        HolisticHandsFreeSelectionOrder.playlistOrder,
      );
    });

    test('rejects invalid speed and nonpositive phase durations', () {
      for (final speed in [49, 201]) {
        expect(
          () => HolisticHandsFreePracticeConfig(
            playlist: [paper],
            speedPercent: speed,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => HolisticHandsFreePracticeConfig(
          playlist: [paper],
          thinkingDelay: Duration.zero,
        ),
        throwsArgumentError,
      );
      expect(
        () => HolisticHandsFreePracticeConfig(
          playlist: [paper],
          answerDisplayDwell: const Duration(microseconds: -1),
        ),
        throwsArgumentError,
      );
      expect(
        () => HolisticHandsFreePracticeConfig(playlist: []),
        throwsArgumentError,
      );
      expect(
        () => handsFreeFlashStreamDuration(FlashLevel.zsk20, speedPercent: 201),
        throwsArgumentError,
      );
      expect(
        () => paper.displayedProblemDuration(speedPercent: 49),
        throwsArgumentError,
      );
    });
  });
}
