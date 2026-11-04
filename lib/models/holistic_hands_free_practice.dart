import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/level_definitions.dart';

/// Activities that can be placed in a holistic hands-free practice playlist.
enum HolisticPracticeActivity {
  mitoriAnzan,
  multiplicationAnzan,
  divisionAnzan,
  flashAnzan,
}

/// A validated, typed item in a holistic hands-free practice playlist.
///
/// The factories resolve the selected [Kyuui] for its organization and reject
/// combinations that have no corresponding level. Repeated entries are
/// allowed by [HolisticHandsFreePracticeConfig].
sealed class HolisticPracticePlaylistEntry {
  const HolisticPracticePlaylistEntry._({
    required this.activity,
    required this.denomination,
    required this.kyuui,
  });

  factory HolisticPracticePlaylistEntry.paperAnzan({
    required HolisticPracticeActivity activity,
    required Denomination denomination,
    required Kyuui kyuui,
  }) {
    final subject = switch (activity) {
      HolisticPracticeActivity.mitoriAnzan => HandsFreeAnzanSubject.mitori,
      HolisticPracticeActivity.multiplicationAnzan =>
        HandsFreeAnzanSubject.multiplication,
      HolisticPracticeActivity.divisionAnzan => HandsFreeAnzanSubject.division,
      HolisticPracticeActivity.flashAnzan => null,
    };
    if (subject == null) {
      throw ArgumentError.value(
        activity,
        'activity',
        'Flash Anzan must use the flashAnzan factory',
      );
    }

    final gradeMapping = switch (denomination) {
      Denomination.nisshou => KyuuiDenomination.ns,
      Denomination.zenshuren => KyuuiDenomination.zs,
      Denomination.kyoukai => null,
    };
    final level = handsFreeAnzanSubjectsFor(kyuui)[subject];
    if (gradeMapping == null ||
        !_mappingContains(gradeMapping, kyuui) ||
        level == null ||
        level.levelInfo.denomination != denomination) {
      throw ArgumentError.value(
        (activity: activity, denomination: denomination, kyuui: kyuui),
        'entry',
        'The paper Anzan activity is unavailable for this organization and kyuui',
      );
    }

    return PaperAnzanPlaylistEntry._(
      activity: activity,
      denomination: denomination,
      kyuui: kyuui,
      level: level,
    );
  }

  factory HolisticPracticePlaylistEntry.flashAnzan({
    required Denomination denomination,
    required Kyuui kyuui,
  }) {
    final gradeMapping = switch (denomination) {
      Denomination.zenshuren => KyuuiDenomination.zsFlash,
      Denomination.kyoukai => KyuuiDenomination.kkFlash,
      Denomination.nisshou => null,
    };
    final level = kyuui.flash;
    if (gradeMapping == null ||
        !_mappingContains(gradeMapping, kyuui) ||
        level == null ||
        level.levelInfo.denomination != denomination) {
      throw ArgumentError.value(
        (denomination: denomination, kyuui: kyuui),
        'entry',
        'Flash Anzan is unavailable for this organization and kyuui',
      );
    }

    return FlashAnzanPlaylistEntry._(
      denomination: denomination,
      kyuui: kyuui,
      level: level,
    );
  }

  final HolisticPracticeActivity activity;
  final Denomination denomination;
  final Kyuui kyuui;

  /// The resolved paper or flash level for this entry.
  Level get level;

  /// Duration of the displayed problem/number stream only.
  ///
  /// Any thinking delay and answer-display dwell are separate phases and are
  /// deliberately not included in this duration.
  Duration displayedProblemDuration({required int speedPercent});
}

/// A paper Mitorizan, multiplication, or division Anzan playlist entry.
final class PaperAnzanPlaylistEntry extends HolisticPracticePlaylistEntry {
  const PaperAnzanPlaylistEntry._({
    required super.activity,
    required super.denomination,
    required super.kyuui,
    required this.level,
  }) : super._();

  @override
  final PaperProblemLevel level;

  @override
  Duration displayedProblemDuration({required int speedPercent}) =>
      _displayedPaperProblemDuration(level, speedPercent);
}

/// A Flash Anzan playlist entry.
final class FlashAnzanPlaylistEntry extends HolisticPracticePlaylistEntry {
  const FlashAnzanPlaylistEntry._({
    required super.denomination,
    required super.kyuui,
    required this.level,
  }) : super._(activity: HolisticPracticeActivity.flashAnzan);

  @override
  final FlashLevel level;

  @override
  Duration displayedProblemDuration({required int speedPercent}) =>
      handsFreeFlashStreamDuration(level, speedPercent: speedPercent);
}

/// Validated settings and an immutable playlist for hands-free practice.
class HolisticHandsFreePracticeConfig {
  HolisticHandsFreePracticeConfig({
    required Iterable<HolisticPracticePlaylistEntry> playlist,
    this.speedPercent = 100,
    this.thinkingDelay = const Duration(seconds: 5),
    this.answerDisplayDwell = const Duration(seconds: 5),
  }) : playlist = List.unmodifiable(playlist) {
    _validateSpeedPercent(speedPercent);
    if (this.playlist.isEmpty) {
      throw ArgumentError.value(playlist, 'playlist', 'Must not be empty');
    }
    _validatePositiveDuration(thinkingDelay, 'thinkingDelay');
    _validatePositiveDuration(answerDisplayDwell, 'answerDisplayDwell');
  }

  /// An immutable copy of the playlist. Duplicate entries remain in order.
  final List<HolisticPracticePlaylistEntry> playlist;
  final int speedPercent;

  /// Pause after a flash number stream and before revealing its answer.
  final Duration thinkingDelay;

  /// Time for which an answer remains visible, independent of [thinkingDelay].
  final Duration answerDisplayDwell;

  static void _validatePositiveDuration(Duration duration, String name) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, name, 'Must be positive');
    }
  }
}

/// Scales a Flash Anzan stream baseline by the shared practice speed.
///
/// At 100%, the stream uses [FlashLevel.secondsPerProblem]. A higher speed
/// shortens the stream proportionally. Thinking and answer-display phases are
/// not included.
Duration handsFreeFlashStreamDuration(
  FlashLevel level, {
  required int speedPercent,
}) {
  _validateSpeedPercent(speedPercent);
  if (!level.secondsPerProblem.isFinite || level.secondsPerProblem <= 0) {
    throw ArgumentError.value(
      level.secondsPerProblem,
      'level.secondsPerProblem',
      'Must be positive and finite',
    );
  }

  final baselineMicroseconds =
      level.secondsPerProblem * Duration.microsecondsPerSecond;
  return Duration(
    microseconds: (baselineMicroseconds * 100 / speedPercent).round(),
  );
}

Duration _displayedPaperProblemDuration(
  PaperProblemLevel level,
  int speedPercent,
) {
  _validateSpeedPercent(speedPercent);
  return handsFreeProblemDuration(level, speedPercent: speedPercent.toDouble());
}

void _validateSpeedPercent(int speedPercent) {
  if (speedPercent < 50 || speedPercent > 200) {
    throw ArgumentError.value(speedPercent, 'speedPercent', 'Must be 50–200');
  }
}

bool _mappingContains(KyuuiDenomination mapping, Kyuui kyuui) => [
  mapping.k1,
  mapping.k2,
  mapping.k3,
  mapping.k4,
  mapping.k5,
  mapping.k6,
  mapping.k7,
  mapping.k8,
  mapping.k9,
  mapping.k10,
  mapping.k11,
  mapping.k12,
  mapping.k13,
  mapping.k14,
  mapping.k15,
  mapping.k16,
  mapping.k17,
  mapping.k18,
  mapping.k19,
  mapping.k20,
  mapping.kj1,
  mapping.kj2,
  mapping.kj3,
  mapping.dan,
  mapping.d1,
  mapping.d2,
  mapping.d3,
  mapping.d4,
  mapping.d5,
  mapping.d6,
  mapping.d7,
  mapping.d8,
  mapping.d9,
  mapping.d10,
].contains(kyuui);
