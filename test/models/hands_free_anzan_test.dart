import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/level_definitions.dart';

void main() {
  group('hands-free Anzan duration', () {
    final level = DivMultLevel.zsmk9; // 7 minutes for 15 problems.

    test('uses exam-average time as the baseline', () {
      expect(examAverageTimePerProblem(level), const Duration(seconds: 28));
    });

    test('scales display/solve interval by speed percentage', () {
      expect(
        handsFreeProblemDuration(level, speedPercent: 50),
        const Duration(seconds: 56),
      );
      expect(
        handsFreeProblemDuration(level, speedPercent: 100),
        const Duration(seconds: 28),
      );
      expect(
        handsFreeProblemDuration(level, speedPercent: 200),
        const Duration(seconds: 14),
      );
    });

    test('preserves fractional duration to the nearest microsecond', () {
      expect(
        handsFreeProblemDuration(level, speedPercent: 33),
        const Duration(microseconds: 84_848_485),
      );
    });

    test('rejects nonpositive and non-finite speed percentages', () {
      expect(
        () => handsFreeProblemDuration(level, speedPercent: 0),
        throwsArgumentError,
      );
      expect(
        () => handsFreeProblemDuration(level, speedPercent: -1),
        throwsArgumentError,
      );
      expect(
        () => handsFreeProblemDuration(level, speedPercent: double.nan),
        throwsArgumentError,
      );
    });
  });

  group('hands-free Anzan subject availability', () {
    test('returns only subjects available for the selected kyuui', () {
      expect(handsFreeAnzanSubjectsFor(Kyuui.nsk10), {
        HandsFreeAnzanSubject.mitori: Kyuui.nsk10.mitoriAnzan,
      });
    });

    test('includes available mitori, multiplication, and division Anzan', () {
      final kyuui = Kyuui.zsk6;

      expect(handsFreeAnzanSubjectsFor(kyuui), {
        HandsFreeAnzanSubject.mitori: kyuui.mitoriAnzan,
        HandsFreeAnzanSubject.multiplication: kyuui.multAnzan,
        HandsFreeAnzanSubject.division: kyuui.divAnzan,
      });
    });
  });
}
