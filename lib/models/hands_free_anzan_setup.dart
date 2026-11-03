import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/level_definitions.dart';

/// The grade and organization context selected in the Combined Subjects menu.
class HandsFreeAnzanSetupRequest {
  const HandsFreeAnzanSetupRequest({
    required this.kyuui,
    required this.denomination,
  });

  final Kyuui kyuui;
  final KyuuiDenomination denomination;
}

enum HandsFreeAnzanMode { mitori, multiplication, division, mixed }

/// Immutable settings passed from the setup page to the next hands-free step.
///
/// This configuration intentionally contains no session or problem state. A
/// later stage can use [selectedLevels] to build the selected problem sources.
class HandsFreeAnzanSetupConfig {
  HandsFreeAnzanSetupConfig({
    required this.kyuui,
    required this.denomination,
    required this.mode,
    required Set<HandsFreeAnzanSubject> selectedSubjects,
    required this.speedPercent,
    required this.answerDisplayDwell,
  }) : selectedSubjects = Set.unmodifiable(selectedSubjects) {
    if (speedPercent < 50 || speedPercent > 200) {
      throw ArgumentError.value(speedPercent, 'speedPercent', 'Must be 50–200');
    }
    if (answerDisplayDwell.inMicroseconds % Duration.microsecondsPerSecond !=
            0 ||
        answerDisplayDwell.inSeconds < 1 ||
        answerDisplayDwell.inSeconds > 15) {
      throw ArgumentError.value(
        answerDisplayDwell,
        'answerDisplayDwell',
        'Must be a whole number of seconds from 1 to 15',
      );
    }
    if (this.selectedSubjects.isEmpty) {
      throw ArgumentError.value(
        selectedSubjects,
        'selectedSubjects',
        'At least one subject must be selected',
      );
    }

    final available = handsFreeAnzanSubjectsFor(kyuui);
    if (!available.keys.toSet().containsAll(this.selectedSubjects)) {
      throw ArgumentError.value(
        selectedSubjects,
        'selectedSubjects',
        'All selected subjects must be available for the selected kyuui',
      );
    }

    final singleSubject = switch (mode) {
      HandsFreeAnzanMode.mitori => HandsFreeAnzanSubject.mitori,
      HandsFreeAnzanMode.multiplication => HandsFreeAnzanSubject.multiplication,
      HandsFreeAnzanMode.division => HandsFreeAnzanSubject.division,
      HandsFreeAnzanMode.mixed => null,
    };
    if (singleSubject != null &&
        (this.selectedSubjects.length != 1 ||
            !this.selectedSubjects.contains(singleSubject))) {
      throw ArgumentError.value(
        selectedSubjects,
        'selectedSubjects',
        'Selected subjects must match the selected mode',
      );
    }

    selectedLevels = Map.unmodifiable({
      for (final subject in this.selectedSubjects) subject: available[subject]!,
    });
  }

  final Kyuui kyuui;
  final KyuuiDenomination denomination;
  final HandsFreeAnzanMode mode;
  final Set<HandsFreeAnzanSubject> selectedSubjects;
  final int speedPercent;
  final Duration answerDisplayDwell;
  late final Map<HandsFreeAnzanSubject, PaperProblemLevel> selectedLevels;
}
