// Generated localization code for Sorokun.
// Localization resources updated by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sorokun!';

  @override
  String get languageLabel => '言語 / Language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get englishLanguage => 'English';

  @override
  String get englishTranslationDisclosure =>
      'English interface translations were prepared with LLM assistance; Japanese is the original text. Corrections are welcome.';

  @override
  String get keypadPosition => 'Keypad position';

  @override
  String get leftHanded => 'Left-handed';

  @override
  String get rightHanded => 'Right-handed';

  @override
  String get keypadLayout => 'Keypad layout';

  @override
  String get screenBrightness => 'Appearance';

  @override
  String get automatic => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get color => 'Color';

  @override
  String get homeCombinedLine1 => 'Combined';

  @override
  String get homeCombinedLine2 => 'Practice';

  @override
  String get homeSelectSubject => 'Choose a subject';

  @override
  String get homeFlashLine1 => 'Flash';

  @override
  String get homeFlashLine2 => 'Anzan';

  @override
  String get homeExam => 'Exam';

  @override
  String get homeFree => 'Free';

  @override
  String get credits => 'Credits';

  @override
  String get creditsDevelopment => 'Development';

  @override
  String get developerRole => 'Developer';

  @override
  String get originalSourceIntro => 'Original Sorokun source code:';

  @override
  String get forkSourceIntro => 'Source code for this fork:';

  @override
  String get forkModificationNotice =>
      'Originally by Chet Lin. Modified by Vultaire (2026-11-01). Removed yomiagezan and VOICEVOX and added web-build support.';

  @override
  String get forkDevelopmentDisclosure =>
      'Changes in this fork were made through agentic development using an LLM, under Vultaire\'s direction.';

  @override
  String get localizationUpdateNotice =>
      'Japanese/English interface localization was added on 2026-11-02.';

  @override
  String get fontCredits => 'Fonts';

  @override
  String get abacusBeadFont => 'Soroban bead font';

  @override
  String get sorobanNumeralFont => 'Soroban numeral font';

  @override
  String get license => 'License';

  @override
  String get noWarrantyLicenseNotice =>
      'This software comes with no warranty. Redistribution and modification are permitted under GPL v3.0. See the link above for the full license.';

  @override
  String get exitDialogTitle => 'Exit practice?';

  @override
  String get exitDialogMessage => 'Submit your answers or quit this session.';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get quit => 'Quit';

  @override
  String get back => 'Back';

  @override
  String get combinedSubjectsTitle => 'Combined practice';

  @override
  String get organizationZenshuren => 'Zenshuren';

  @override
  String get organizationNisshuren => 'Nisshuren';

  @override
  String get organizationFlashAnzan => 'Japan Flash Anzan Association';

  @override
  String get selectorZenshuren => 'Zenshuren';

  @override
  String get selectorNisshuren => 'Nisshuren';

  @override
  String get selectorFlashAnzan => 'Japan Flash Anzan Association';

  @override
  String get zenshurenOrganizationSubtitle =>
      'The League for Soroban\nEducation of Japan';

  @override
  String get nisshurenOrganizationSubtitle =>
      'The League of Japan\nAbacus Associations';

  @override
  String organizationSubtitleLine(String subtitle) {
    return '($subtitle)';
  }

  @override
  String kyuGrade(int grade) {
    String _temp0 = intl.Intl.pluralLogic(
      grade,
      locale: localeName,
      other: '$grade kyu',
      one: '$grade kyu',
    );
    return '$_temp0';
  }

  @override
  String preKyuGrade(int grade) {
    return 'Pre-$grade kyu';
  }

  @override
  String get danGroupGrade => 'Dan';

  @override
  String danGrade(String grade) {
    return '$grade dan';
  }

  @override
  String get rankPreShodan => 'Pre-1 dan';

  @override
  String get rankShodan => '1 dan';

  @override
  String get rankPreNidan => 'Pre-2 dan';

  @override
  String get rankNidan => '2 dan';

  @override
  String get rankPreSandan => 'Pre-3 dan';

  @override
  String get rankSandan => '3 dan';

  @override
  String get rankPreYondan => 'Pre-4 dan';

  @override
  String get rankYondan => '4 dan';

  @override
  String get rankPreGodan => 'Pre-5 dan';

  @override
  String get rankGodan => '5 dan';

  @override
  String get rankPreRokudan => 'Pre-6 dan';

  @override
  String get rankRokudan => '6 dan';

  @override
  String get rankNanadan => '7 dan';

  @override
  String get rankHachidan => '8 dan';

  @override
  String get rankKudan => '9 dan';

  @override
  String get rankJudan => '10 dan';

  @override
  String get paperPractice => 'Practice';

  @override
  String get paperExam => 'Exam';

  @override
  String get mitoriZan => 'Mitorizan (+/−)';

  @override
  String get division => 'Division';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get mitoriAnzan => 'Mental Mitorizan';

  @override
  String get divisionAnzan => 'Mental division';

  @override
  String get multiplicationAnzan => 'Mental multiplication';

  @override
  String get flashAnzanSubject => 'Flash Anzan';

  @override
  String gradeActivity(String grade, String activity) {
    return '$grade $activity';
  }

  @override
  String get start => 'Start';

  @override
  String timeLimit(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minute',
    );
    return 'Time limit: $_temp0';
  }

  @override
  String problemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems',
      one: '$count problem',
    );
    return '$_temp0';
  }

  @override
  String pointsEach(int points, int maximum) {
    return '$points points each (max $maximum points)';
  }

  @override
  String passingScore(int score) {
    return 'Passing score: $score+ points';
  }

  @override
  String oneProblemDigits(String range) {
    return '$range digits per problem';
  }

  @override
  String methodDigits(String method, String range) {
    return '$method: $range digits total';
  }

  @override
  String get jippou => 'Multiplicand + multiplier';

  @override
  String get houshou => 'Divisor + quotient';

  @override
  String get mitorizanExplanation =>
      'Mitorizan (+/−): add and subtract a vertical list of numbers in sequence.';

  @override
  String get flashExamTitle => 'Flash Anzan Practice Exam';

  @override
  String get flashFreeTitle => 'Free Flash Anzan';

  @override
  String get flashDigitsLabel => 'Digits';

  @override
  String get flashKuchiLabel => 'Numbers';

  @override
  String digitsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' digits',
      one: ' digit',
    );
    return '$_temp0';
  }

  @override
  String kuchiUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' numbers',
      one: ' number',
    );
    return '$_temp0';
  }

  @override
  String get secondsUnit => ' sec';

  @override
  String flashAllProblems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems',
      one: '$count problem',
    );
    return '$_temp0, 10 points each';
  }

  @override
  String flashPassingScore(int score) {
    return 'Pass with $score points';
  }

  @override
  String get noCarry => 'No carrying';

  @override
  String get displayInterval => 'Display interval';

  @override
  String get blankInterval => 'Blank interval';

  @override
  String get millisecondsShort => 'ms';

  @override
  String get flashAnswerPrompt => 'Enter your answer.';

  @override
  String get repeatProblem => 'Try again';

  @override
  String get nextProblem => 'Next problem';

  @override
  String get grade => 'Results';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get answer => 'Answer';

  @override
  String get answerTime => 'Answer time';

  @override
  String answerTimeValue(String time) {
    return '$time sec';
  }

  @override
  String get time => 'Time';

  @override
  String get reviewIncorrect => 'Review incorrect answers';

  @override
  String get tryAgain => 'Try again';

  @override
  String get returnHome => 'Return to main menu';

  @override
  String get returnToSettings => 'Return to settings';

  @override
  String pointsOutOf(int maximum) {
    return 'out of $maximum points';
  }

  @override
  String get pointsUnit => 'points';

  @override
  String get passed => 'Passed';

  @override
  String get failed => 'Not passed';

  @override
  String get unknownLevelType => 'Unknown level type';

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get practiceComplete => 'Complete!';

  @override
  String get roundingDecimalNotice => 'Note: Round to the nearest hundredth.';

  @override
  String get roundingIntegerNotice =>
      'Note: Round to the nearest whole number.';

  @override
  String get backspaceSemantics => 'Delete the last digit; hold to clear';

  @override
  String get submitSemantics => 'Submit answer';

  @override
  String get themeColorWheelSemantics => 'Choose a theme color';

  @override
  String get standardKeypadLayout => 'Standard keypad layout';

  @override
  String get telephoneKeypadLayout => 'Telephone keypad layout';

  @override
  String get increaseValue => 'Increase value';

  @override
  String get decreaseValue => 'Decrease value';

  @override
  String get increaseTime => 'Increase display time';

  @override
  String get decreaseTime => 'Decrease display time';
}
