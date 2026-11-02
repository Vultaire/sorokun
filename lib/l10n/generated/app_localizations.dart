// Generated localization code for Sorokun.
// Localization resources updated by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'Sorokun'**
  String get appTitle;

  /// No description provided for @languageLabel.
  ///
  /// In ja, this message translates to:
  /// **'言語 / Language'**
  String get languageLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'アプリ設定'**
  String get settingsTitle;

  /// No description provided for @japaneseLanguage.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get japaneseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @englishTranslationDisclosure.
  ///
  /// In ja, this message translates to:
  /// **'英語インターフェースの翻訳にはLLMを使用しています。日本語が原文です。誤訳のご指摘を歓迎します。'**
  String get englishTranslationDisclosure;

  /// No description provided for @keypadPosition.
  ///
  /// In ja, this message translates to:
  /// **'テンキーの配置'**
  String get keypadPosition;

  /// No description provided for @leftHanded.
  ///
  /// In ja, this message translates to:
  /// **'左利き'**
  String get leftHanded;

  /// No description provided for @rightHanded.
  ///
  /// In ja, this message translates to:
  /// **'右利き'**
  String get rightHanded;

  /// No description provided for @keypadLayout.
  ///
  /// In ja, this message translates to:
  /// **'キーレイアウト'**
  String get keypadLayout;

  /// No description provided for @screenBrightness.
  ///
  /// In ja, this message translates to:
  /// **'画面の明るさ'**
  String get screenBrightness;

  /// No description provided for @automatic.
  ///
  /// In ja, this message translates to:
  /// **'自動'**
  String get automatic;

  /// No description provided for @theme.
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get theme;

  /// No description provided for @color.
  ///
  /// In ja, this message translates to:
  /// **'カラー'**
  String get color;

  /// No description provided for @homeCombinedLine1.
  ///
  /// In ja, this message translates to:
  /// **'総合'**
  String get homeCombinedLine1;

  /// No description provided for @homeCombinedLine2.
  ///
  /// In ja, this message translates to:
  /// **'種目'**
  String get homeCombinedLine2;

  /// No description provided for @homeSelectSubject.
  ///
  /// In ja, this message translates to:
  /// **'種目を選ぶ'**
  String get homeSelectSubject;

  /// No description provided for @homeFlashLine1.
  ///
  /// In ja, this message translates to:
  /// **'ﾌﾗｯｼｭ'**
  String get homeFlashLine1;

  /// No description provided for @homeFlashLine2.
  ///
  /// In ja, this message translates to:
  /// **'暗算'**
  String get homeFlashLine2;

  /// No description provided for @homeExam.
  ///
  /// In ja, this message translates to:
  /// **'検定'**
  String get homeExam;

  /// No description provided for @homeFree.
  ///
  /// In ja, this message translates to:
  /// **'フリー'**
  String get homeFree;

  /// No description provided for @credits.
  ///
  /// In ja, this message translates to:
  /// **'クレジット'**
  String get credits;

  /// No description provided for @creditsDevelopment.
  ///
  /// In ja, this message translates to:
  /// **'開発'**
  String get creditsDevelopment;

  /// No description provided for @developerRole.
  ///
  /// In ja, this message translates to:
  /// **'開発者'**
  String get developerRole;

  /// No description provided for @originalSourceIntro.
  ///
  /// In ja, this message translates to:
  /// **'元のそろくんのソースコードはこちらで公開されています：'**
  String get originalSourceIntro;

  /// No description provided for @forkSourceIntro.
  ///
  /// In ja, this message translates to:
  /// **'このフォークのソースコード：'**
  String get forkSourceIntro;

  /// No description provided for @forkModificationNotice.
  ///
  /// In ja, this message translates to:
  /// **'原作: Chet Lin。Vultaire による改変版です（2026-11-01）。読み上げ算と VOICEVOX を削除し、Web ビルド対応を行いました。'**
  String get forkModificationNotice;

  /// No description provided for @forkDevelopmentDisclosure.
  ///
  /// In ja, this message translates to:
  /// **'このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。'**
  String get forkDevelopmentDisclosure;

  /// No description provided for @localizationUpdateNotice.
  ///
  /// In ja, this message translates to:
  /// **'日本語・English インターフェースのローカライズを2026-11-02に追加しました。'**
  String get localizationUpdateNotice;

  /// No description provided for @fontCredits.
  ///
  /// In ja, this message translates to:
  /// **'フォント'**
  String get fontCredits;

  /// No description provided for @abacusBeadFont.
  ///
  /// In ja, this message translates to:
  /// **'そろばん玉のフォント'**
  String get abacusBeadFont;

  /// No description provided for @sorobanNumeralFont.
  ///
  /// In ja, this message translates to:
  /// **'珠算の数字のフォント'**
  String get sorobanNumeralFont;

  /// No description provided for @license.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get license;

  /// No description provided for @noWarrantyLicenseNotice.
  ///
  /// In ja, this message translates to:
  /// **'本ソフトウェアは無保証です。GPL v3.0 の条件に従って再配布・改変できます。ライセンス全文は上記リンクから確認できます。'**
  String get noWarrantyLicenseNotice;

  /// No description provided for @exitDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'終了しますか？'**
  String get exitDialogTitle;

  /// No description provided for @exitDialogMessage.
  ///
  /// In ja, this message translates to:
  /// **'提出するか、途中でやめるか選んでください。'**
  String get exitDialogMessage;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In ja, this message translates to:
  /// **'提出'**
  String get submit;

  /// No description provided for @quit.
  ///
  /// In ja, this message translates to:
  /// **'やめる'**
  String get quit;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// No description provided for @combinedSubjectsTitle.
  ///
  /// In ja, this message translates to:
  /// **'総合種目'**
  String get combinedSubjectsTitle;

  /// Use the original Japanese organization name in Japanese; use its romanized name in English, without claiming an official English title.
  ///
  /// In ja, this message translates to:
  /// **'全国珠算教育連盟'**
  String get organizationZenshuren;

  /// Use the original Japanese organization name in Japanese; use its romanized name in English, without claiming an official English title.
  ///
  /// In ja, this message translates to:
  /// **'日本珠算連盟'**
  String get organizationNisshuren;

  /// Use the original Japanese organization name in Japanese; use this romanized descriptive label in English, not as a verified official English title.
  ///
  /// In ja, this message translates to:
  /// **'日本ﾌﾗｯｼｭ暗算協会'**
  String get organizationFlashAnzan;

  /// No description provided for @selectorZenshuren.
  ///
  /// In ja, this message translates to:
  /// **'全珠連'**
  String get selectorZenshuren;

  /// No description provided for @selectorNisshuren.
  ///
  /// In ja, this message translates to:
  /// **'日珠連'**
  String get selectorNisshuren;

  /// No description provided for @selectorFlashAnzan.
  ///
  /// In ja, this message translates to:
  /// **'協会'**
  String get selectorFlashAnzan;

  /// Descriptive, non-official gloss for the selector: this organization is associated with a soroban grade system.
  ///
  /// In ja, this message translates to:
  /// **'珠算の級位制度'**
  String get sorobanOrganizationGloss;

  /// Descriptive, non-official gloss for the organization responsible for these Flash Anzan grade labels.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ暗算の級位制度'**
  String get flashAnzanOrganizationGloss;

  /// A compact parenthesized descriptive gloss displayed below a romanized organization name.
  ///
  /// In ja, this message translates to:
  /// **'（{gloss}）'**
  String organizationGlossLine(String gloss);

  /// Standard kyu grade label.
  ///
  /// In ja, this message translates to:
  /// **'{grade, plural, other{{grade}級}}'**
  String kyuGrade(int grade);

  /// Preparatory kyu grade label.
  ///
  /// In ja, this message translates to:
  /// **'準{grade}級'**
  String preKyuGrade(int grade);

  /// No description provided for @danGroupGrade.
  ///
  /// In ja, this message translates to:
  /// **'段位'**
  String get danGroupGrade;

  /// Dan grade label. Use the traditional Japanese rank names.
  ///
  /// In ja, this message translates to:
  /// **'{grade, select, 1{初段} 2{二段} 3{三段} 4{四段} 5{五段} 6{六段} 7{七段} 8{八段} 9{九段} 10{十段} other{{grade}段}}'**
  String danGrade(String grade);

  /// No description provided for @rankPreShodan.
  ///
  /// In ja, this message translates to:
  /// **'準初段'**
  String get rankPreShodan;

  /// No description provided for @rankShodan.
  ///
  /// In ja, this message translates to:
  /// **'初段'**
  String get rankShodan;

  /// No description provided for @rankPreNidan.
  ///
  /// In ja, this message translates to:
  /// **'準二段'**
  String get rankPreNidan;

  /// No description provided for @rankNidan.
  ///
  /// In ja, this message translates to:
  /// **'二段'**
  String get rankNidan;

  /// No description provided for @rankPreSandan.
  ///
  /// In ja, this message translates to:
  /// **'準三段'**
  String get rankPreSandan;

  /// No description provided for @rankSandan.
  ///
  /// In ja, this message translates to:
  /// **'三段'**
  String get rankSandan;

  /// No description provided for @rankPreYondan.
  ///
  /// In ja, this message translates to:
  /// **'準四段'**
  String get rankPreYondan;

  /// No description provided for @rankYondan.
  ///
  /// In ja, this message translates to:
  /// **'四段'**
  String get rankYondan;

  /// No description provided for @rankPreGodan.
  ///
  /// In ja, this message translates to:
  /// **'準五段'**
  String get rankPreGodan;

  /// No description provided for @rankGodan.
  ///
  /// In ja, this message translates to:
  /// **'五段'**
  String get rankGodan;

  /// No description provided for @rankPreRokudan.
  ///
  /// In ja, this message translates to:
  /// **'準六段'**
  String get rankPreRokudan;

  /// No description provided for @rankRokudan.
  ///
  /// In ja, this message translates to:
  /// **'六段'**
  String get rankRokudan;

  /// No description provided for @rankNanadan.
  ///
  /// In ja, this message translates to:
  /// **'七段'**
  String get rankNanadan;

  /// No description provided for @rankHachidan.
  ///
  /// In ja, this message translates to:
  /// **'八段'**
  String get rankHachidan;

  /// No description provided for @rankKudan.
  ///
  /// In ja, this message translates to:
  /// **'九段'**
  String get rankKudan;

  /// No description provided for @rankJudan.
  ///
  /// In ja, this message translates to:
  /// **'十段'**
  String get rankJudan;

  /// No description provided for @paperPractice.
  ///
  /// In ja, this message translates to:
  /// **'練習'**
  String get paperPractice;

  /// No description provided for @paperExam.
  ///
  /// In ja, this message translates to:
  /// **'検定'**
  String get paperExam;

  /// Compact practice-mode label for Mitorizan (+/−); keep the English term Mitorizan compact.
  ///
  /// In ja, this message translates to:
  /// **'みとり算'**
  String get mitoriZan;

  /// No description provided for @division.
  ///
  /// In ja, this message translates to:
  /// **'わり算'**
  String get division;

  /// No description provided for @multiplication.
  ///
  /// In ja, this message translates to:
  /// **'かけ算'**
  String get multiplication;

  /// Mental-arithmetic version of Mitorizan.
  ///
  /// In ja, this message translates to:
  /// **'みとり暗算'**
  String get mitoriAnzan;

  /// No description provided for @divisionAnzan.
  ///
  /// In ja, this message translates to:
  /// **'わり暗算'**
  String get divisionAnzan;

  /// No description provided for @multiplicationAnzan.
  ///
  /// In ja, this message translates to:
  /// **'かけ暗算'**
  String get multiplicationAnzan;

  /// No description provided for @flashAnzanSubject.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ暗算'**
  String get flashAnzanSubject;

  /// Grade label paired with a practice subject.
  ///
  /// In ja, this message translates to:
  /// **'{grade}の{activity}'**
  String gradeActivity(String grade, String activity);

  /// No description provided for @start.
  ///
  /// In ja, this message translates to:
  /// **'スタート'**
  String get start;

  /// Time limit in minutes.
  ///
  /// In ja, this message translates to:
  /// **'制限時間：{minutes}分'**
  String timeLimit(int minutes);

  /// Number of questions in a practice set.
  ///
  /// In ja, this message translates to:
  /// **'問題数：{count}題'**
  String problemCount(int count);

  /// Points awarded per problem and maximum possible score.
  ///
  /// In ja, this message translates to:
  /// **'各{points}点 ({maximum}点満点)'**
  String pointsEach(int points, int maximum);

  /// Minimum passing score.
  ///
  /// In ja, this message translates to:
  /// **'合格点：{score}点以上'**
  String passingScore(int score);

  /// Number of digits in each Mitori-zan problem.
  ///
  /// In ja, this message translates to:
  /// **'一題あたり{range}字'**
  String oneProblemDigits(String range);

  /// Digit range for a multiplication or division method.
  ///
  /// In ja, this message translates to:
  /// **'{method}あわせて{range}桁'**
  String methodDigits(String method, String range);

  /// Abbreviation for the two factors (multiplicand and multiplier) whose digits are counted together.
  ///
  /// In ja, this message translates to:
  /// **'実法'**
  String get jippou;

  /// Abbreviation for divisor and quotient digits counted together.
  ///
  /// In ja, this message translates to:
  /// **'法商'**
  String get houshou;

  /// Inline help gloss: explain that Mitorizan is a vertical sequence of addition and subtraction; this appears in an existing details dialog.
  ///
  /// In ja, this message translates to:
  /// **'Mitorizan (+/−)：縦に並んだ数を、足し算・引き算を交互に使って計算します。'**
  String get mitorizanExplanation;

  /// Menu title for Flash Anzan examination practice.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ暗算もぎ検定'**
  String get flashExamTitle;

  /// No description provided for @flashFreeTitle.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ暗算フリー'**
  String get flashFreeTitle;

  /// No description provided for @flashDigitsLabel.
  ///
  /// In ja, this message translates to:
  /// **'桁数'**
  String get flashDigitsLabel;

  /// Number of sequential numbers shown in one Flash Anzan problem.
  ///
  /// In ja, this message translates to:
  /// **'口数'**
  String get flashKuchiLabel;

  /// Unit for the number of digits in one Flash Anzan problem.
  ///
  /// In ja, this message translates to:
  /// **'{count, plural, other{桁}}'**
  String digitsUnit(int count);

  /// Unit for the number of values shown in one Flash Anzan problem.
  ///
  /// In ja, this message translates to:
  /// **'{count, plural, other{口}}'**
  String kuchiUnit(int count);

  /// No description provided for @secondsUnit.
  ///
  /// In ja, this message translates to:
  /// **'秒'**
  String get secondsUnit;

  /// Flash Anzan question count and points per question.
  ///
  /// In ja, this message translates to:
  /// **'全{count}問 各10点'**
  String flashAllProblems(int count);

  /// Passing score for Flash Anzan.
  ///
  /// In ja, this message translates to:
  /// **'{score}点で合格'**
  String flashPassingScore(int score);

  /// No description provided for @noCarry.
  ///
  /// In ja, this message translates to:
  /// **'くりあがりなし'**
  String get noCarry;

  /// No description provided for @displayInterval.
  ///
  /// In ja, this message translates to:
  /// **'表示間隔'**
  String get displayInterval;

  /// No description provided for @blankInterval.
  ///
  /// In ja, this message translates to:
  /// **'消画間隔'**
  String get blankInterval;

  /// No description provided for @millisecondsShort.
  ///
  /// In ja, this message translates to:
  /// **'ms'**
  String get millisecondsShort;

  /// No description provided for @flashAnswerPrompt.
  ///
  /// In ja, this message translates to:
  /// **'答えを記入してください。'**
  String get flashAnswerPrompt;

  /// No description provided for @repeatProblem.
  ///
  /// In ja, this message translates to:
  /// **'もう一回'**
  String get repeatProblem;

  /// No description provided for @nextProblem.
  ///
  /// In ja, this message translates to:
  /// **'次の問題'**
  String get nextProblem;

  /// No description provided for @grade.
  ///
  /// In ja, this message translates to:
  /// **'採点'**
  String get grade;

  /// No description provided for @correct.
  ///
  /// In ja, this message translates to:
  /// **'正解'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In ja, this message translates to:
  /// **'不正解'**
  String get incorrect;

  /// No description provided for @answer.
  ///
  /// In ja, this message translates to:
  /// **'答え'**
  String get answer;

  /// No description provided for @answerTime.
  ///
  /// In ja, this message translates to:
  /// **'回答タイム'**
  String get answerTime;

  /// Time taken to enter an answer, in seconds.
  ///
  /// In ja, this message translates to:
  /// **'{time}秒'**
  String answerTimeValue(String time);

  /// No description provided for @time.
  ///
  /// In ja, this message translates to:
  /// **'タイム'**
  String get time;

  /// No description provided for @reviewIncorrect.
  ///
  /// In ja, this message translates to:
  /// **'間違えた問題を見る'**
  String get reviewIncorrect;

  /// No description provided for @tryAgain.
  ///
  /// In ja, this message translates to:
  /// **'もう一回挑戦する'**
  String get tryAgain;

  /// No description provided for @returnHome.
  ///
  /// In ja, this message translates to:
  /// **'メインメニューに戻る'**
  String get returnHome;

  /// No description provided for @returnToSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定画面に戻る'**
  String get returnToSettings;

  /// Maximum possible points in a result score.
  ///
  /// In ja, this message translates to:
  /// **'{maximum}点満点'**
  String pointsOutOf(int maximum);

  /// No description provided for @pointsUnit.
  ///
  /// In ja, this message translates to:
  /// **'点'**
  String get pointsUnit;

  /// No description provided for @passed.
  ///
  /// In ja, this message translates to:
  /// **'合格'**
  String get passed;

  /// No description provided for @failed.
  ///
  /// In ja, this message translates to:
  /// **'不合格'**
  String get failed;

  /// No description provided for @unknownLevelType.
  ///
  /// In ja, this message translates to:
  /// **'Unknown level type'**
  String get unknownLevelType;

  /// No description provided for @timeUp.
  ///
  /// In ja, this message translates to:
  /// **'時間切れ！'**
  String get timeUp;

  /// No description provided for @practiceComplete.
  ///
  /// In ja, this message translates to:
  /// **'終了！'**
  String get practiceComplete;

  /// No description provided for @roundingDecimalNotice.
  ///
  /// In ja, this message translates to:
  /// **'（注意） 小数第3位未満四捨五入。'**
  String get roundingDecimalNotice;

  /// No description provided for @roundingIntegerNotice.
  ///
  /// In ja, this message translates to:
  /// **'（注意） 整数位未満四捨五入。'**
  String get roundingIntegerNotice;

  /// No description provided for @backspaceSemantics.
  ///
  /// In ja, this message translates to:
  /// **'末尾の数字を削除（長押しですべて消去）'**
  String get backspaceSemantics;

  /// No description provided for @submitSemantics.
  ///
  /// In ja, this message translates to:
  /// **'回答を送信'**
  String get submitSemantics;

  /// No description provided for @themeColorWheelSemantics.
  ///
  /// In ja, this message translates to:
  /// **'テーマカラーを選択'**
  String get themeColorWheelSemantics;

  /// No description provided for @standardKeypadLayout.
  ///
  /// In ja, this message translates to:
  /// **'標準のテンキー配列'**
  String get standardKeypadLayout;

  /// No description provided for @telephoneKeypadLayout.
  ///
  /// In ja, this message translates to:
  /// **'電話式のテンキー配列'**
  String get telephoneKeypadLayout;

  /// No description provided for @increaseValue.
  ///
  /// In ja, this message translates to:
  /// **'値を増やす'**
  String get increaseValue;

  /// No description provided for @decreaseValue.
  ///
  /// In ja, this message translates to:
  /// **'値を減らす'**
  String get decreaseValue;

  /// No description provided for @increaseTime.
  ///
  /// In ja, this message translates to:
  /// **'表示時間を長くする'**
  String get increaseTime;

  /// No description provided for @decreaseTime.
  ///
  /// In ja, this message translates to:
  /// **'表示時間を短くする'**
  String get decreaseTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
