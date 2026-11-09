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
    Locale.fromSubtags(languageCode: 'ja', scriptCode: 'Kana'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'そろくん！'**
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

  /// No description provided for @kanaJapaneseLanguage.
  ///
  /// In ja, this message translates to:
  /// **'かな'**
  String get kanaJapaneseLanguage;

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

  /// Heading and accessible tooltip for the independent-practice grade disclaimer.
  ///
  /// In ja, this message translates to:
  /// **'級位・段位の表示について'**
  String get gradeReferenceTitle;

  /// Clarify that this fork is independent and unofficial, and that its grade and level labels may not match current organizational standards.
  ///
  /// In ja, this message translates to:
  /// **'本フォークのそろくん！は独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携関係はなく、各団体から公認・推奨を受けたものでもありません。アプリ内の級位・段位等は練習用の目安であり、各団体の最新の基準や検定要件と異なる場合があります。最新の要件は各団体にご確認ください。'**
  String get gradeReferenceDisclosure;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// Language heading for the Japanese block of the bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get welcomeJapaneseLanguageHeading;

  /// Title shown above the Japanese welcome copy.
  ///
  /// In ja, this message translates to:
  /// **'そろくん！のフォークをお試しいただき、ありがとうございます。'**
  String get welcomeJapaneseTitle;

  /// Japanese introduction for the first-run bilingual welcome screen, shown before the English block.
  ///
  /// In ja, this message translates to:
  /// **'Chet Linさんが作ったオリジナル版は、iOSでそろばんを学ぶのにとても優れたアプリだと感じました。Webでも使えるようにし、日本語を話さないそろばん学習者にも使ってもらえるよう、英語の基本的なインターフェースを追加することを試みました。このフォークはその成果です。'**
  String get welcomeJapaneseIntro;

  /// Japanese heading for the welcome screen's affiliation and grade-level caveat.
  ///
  /// In ja, this message translates to:
  /// **'団体との関係と級位について'**
  String get welcomeJapaneseDisclaimerHeading;

  /// Japanese statement about this fork's independence, the original app's uncertain affiliation, and the limits of its grade-level references.
  ///
  /// In ja, this message translates to:
  /// **'このフォークは独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携・協力関係もありません。また、公認・推奨も受けていません。オリジナル版もこれらの団体とは公式な関係ではなかったと認識していますが、作者に代わって断言することはできません。\n\n総合種目とフラッシュ暗算の検定モードで選べる級位は、該当する団体の制度をもとにしているようです。フラッシュ暗算のフリーモードは例外で、口数や桁数などを自由に設定して練習できます。これらの級位は、私自身のそろばん学習経験からはおおむね妥当と思われますが、各団体の最新の基準と一つひとつ照合したわけではありません。内容が不完全であったり、現在の検定要件と異なったりする可能性があり、一致を保証するものではありません。現在そろばん教室に通っている方は、ご自身のレベルに適した練習内容について先生にご相談ください。最新の検定要件は各団体にご確認ください。'**
  String get welcomeJapaneseDisclaimer;

  /// Japanese closing note and attribution for the bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'このフォークでは、オリジナル版の読み上げ算を削除し、Web対応や英語インターフェースなどを追加しました。無料の練習用アプリとして提供しており、資格の認定や検定の合格を保証するものではありません。\n\nお楽しみいただければ幸いです。原作者のChet Linさん、素晴らしいアプリをありがとうございます。\n\n— Paul Goins (Vultaire)'**
  String get welcomeJapaneseClosing;

  /// Language heading for the English block of the bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get welcomeEnglishLanguageHeading;

  /// Title shown above the English welcome copy.
  ///
  /// In ja, this message translates to:
  /// **'Thank you for trying my fork of Sorokun!'**
  String get welcomeEnglishTitle;

  /// English introduction for the first-run bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'I found Chet Lin\'s original Sorokun! to be an excellent study app for iOS. I wanted to experiment with bringing it to the web and adding a basic English interface for people studying soroban who do not speak Japanese. This fork is the result of that experiment.'**
  String get welcomeEnglishIntro;

  /// English heading for the welcome screen's affiliation and grade-level caveat.
  ///
  /// In ja, this message translates to:
  /// **'About affiliations and grade levels'**
  String get welcomeEnglishDisclaimerHeading;

  /// English statement about this fork's independence and the limits of its grade-level references.
  ///
  /// In ja, this message translates to:
  /// **'This fork is an independent, unofficial practice app. It is not an official program of Zenshuren, Nisshuren, or the Japan Flash Anzan Association, and it is not affiliated with or endorsed by any of them. To the best of my knowledge, the original Sorokun! was not officially affiliated with these organizations either, though I cannot speak for its author.\n\nThe selectable grade levels in Soroban Practice and Flash Anzan Exam appear to be modeled on the relevant organizations\' systems. Based on my experience studying soroban, they seem broadly accurate, but I have not checked each one against the organizations\' current standards. They may be incomplete or out of date, and I cannot guarantee that they match current exam requirements. If you are currently taking soroban classes, please ask your teacher which practice materials are appropriate for your level. For current exam requirements, check with the relevant organization.'**
  String get welcomeEnglishDisclaimer;

  /// English closing note and attribution for the bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'This fork removes the original read-aloud exercises and adds web support, a basic English interface, and other features. It is offered as a free study aid, not as a certification tool or a guarantee of exam readiness.\n\nI hope you enjoy it. To Chet Lin, the original author: thank you for an excellent program.\n\n— Paul Goins (Vultaire)'**
  String get welcomeEnglishClosing;

  /// Intentionally bilingual checkbox label on the welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'次回から表示しない / Do not show this again'**
  String get welcomeDoNotShowAgain;

  /// Dismiss the welcome screen and continue; this is not a consent or waiver action.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get welcomeOk;

  /// Credits button that reopens the bilingual welcome screen.
  ///
  /// In ja, this message translates to:
  /// **'Show welcome screen again'**
  String get welcomeReplayButton;

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

  /// No description provided for @homeHandsFreeLine1.
  ///
  /// In ja, this message translates to:
  /// **'ﾊﾝｽﾞ'**
  String get homeHandsFreeLine1;

  /// No description provided for @homeHandsFreeLine2.
  ///
  /// In ja, this message translates to:
  /// **'ﾌﾘｰ'**
  String get homeHandsFreeLine2;

  /// No description provided for @homeHandsFreeButtonLabel.
  ///
  /// In ja, this message translates to:
  /// **'練習'**
  String get homeHandsFreeButtonLabel;

  /// No description provided for @holisticHandsFreePractice.
  ///
  /// In ja, this message translates to:
  /// **'ハンズフリー総合練習'**
  String get holisticHandsFreePractice;

  /// No description provided for @holisticHandsFreeSetupTitle.
  ///
  /// In ja, this message translates to:
  /// **'ハンズフリー練習設定'**
  String get holisticHandsFreeSetupTitle;

  /// No description provided for @holisticHandsFreeSetupSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'練習する種目を選び、それぞれの設定を行ってください。'**
  String get holisticHandsFreeSetupSubtitle;

  /// No description provided for @holisticDuplicateHint.
  ///
  /// In ja, this message translates to:
  /// **'同じ種目を複数登録すると、その種目をより多く練習できます。'**
  String get holisticDuplicateHint;

  /// No description provided for @holisticSelectionOrderHeading.
  ///
  /// In ja, this message translates to:
  /// **'種目の選び方'**
  String get holisticSelectionOrderHeading;

  /// No description provided for @holisticSelectionOrderPlaylist.
  ///
  /// In ja, this message translates to:
  /// **'リスト順'**
  String get holisticSelectionOrderPlaylist;

  /// No description provided for @holisticSelectionOrderRandom.
  ///
  /// In ja, this message translates to:
  /// **'ランダム'**
  String get holisticSelectionOrderRandom;

  /// ハンズフリー練習リストの番号付き種目を読み上げるためのラベル。
  ///
  /// In ja, this message translates to:
  /// **'種目 {number}'**
  String holisticPlaylistItem(int number);

  /// No description provided for @holisticActivity.
  ///
  /// In ja, this message translates to:
  /// **'種目'**
  String get holisticActivity;

  /// No description provided for @holisticOrganization.
  ///
  /// In ja, this message translates to:
  /// **'団体'**
  String get holisticOrganization;

  /// No description provided for @holisticLevel.
  ///
  /// In ja, this message translates to:
  /// **'級位'**
  String get holisticLevel;

  /// No description provided for @holisticAddItem.
  ///
  /// In ja, this message translates to:
  /// **'種目を追加'**
  String get holisticAddItem;

  /// No description provided for @holisticRemoveItem.
  ///
  /// In ja, this message translates to:
  /// **'種目を削除'**
  String get holisticRemoveItem;

  /// 種目を一つ前へ移動するためのアクセシブルなラベルとツールチップ。
  ///
  /// In ja, this message translates to:
  /// **'種目 {number} を上へ移動'**
  String holisticMoveItemUp(int number);

  /// 種目を一つ後ろへ移動するためのアクセシブルなラベルとツールチップ。
  ///
  /// In ja, this message translates to:
  /// **'種目 {number} を下へ移動'**
  String holisticMoveItemDown(int number);

  /// No description provided for @holisticSpeedHeading.
  ///
  /// In ja, this message translates to:
  /// **'問題の表示速度'**
  String get holisticSpeedHeading;

  /// 総合ハンズフリー練習の共通表示速度。
  ///
  /// In ja, this message translates to:
  /// **'速度：{percent}%'**
  String holisticCurrentSpeed(int percent);

  /// No description provided for @holisticDurationHeading.
  ///
  /// In ja, this message translates to:
  /// **'表示時間'**
  String get holisticDurationHeading;

  /// ハンズフリー練習の問題表示時間または各フェーズの秒数。
  ///
  /// In ja, this message translates to:
  /// **'{seconds}秒'**
  String holisticSecondsValue(String seconds);

  /// No description provided for @holisticThinkingDelayHeading.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ暗算の思考時間'**
  String get holisticThinkingDelayHeading;

  /// No description provided for @holisticAnswerDwellHeading.
  ///
  /// In ja, this message translates to:
  /// **'答えの表示時間'**
  String get holisticAnswerDwellHeading;

  /// フラッシュ暗算の思考時間または答えの表示時間。
  ///
  /// In ja, this message translates to:
  /// **'{seconds}秒'**
  String holisticDelayValue(int seconds);

  /// No description provided for @holisticContinue.
  ///
  /// In ja, this message translates to:
  /// **'ハンズフリー練習を開始'**
  String get holisticContinue;

  /// 総合ハンズフリー練習で問題またはフラッシュ暗算の数字を表示している間のカウントダウン。
  ///
  /// In ja, this message translates to:
  /// **'問題終了まで{seconds}秒'**
  String holisticProblemCountdown(int seconds);

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
  /// **'原作: Chet Lin。Vultaire による改変版です。最終更新日: 2026-11-09。\n\n• 読み上げ算と VOICEVOX を削除しました。\n• Web 対応を追加しました。\n• 英語・日本語・かな日本語の表示を追加しました。\n• ハンズフリー暗算を追加しました。\n• PC キーボード入力を追加しました。'**
  String get forkModificationNotice;

  /// No description provided for @forkDevelopmentDisclosure.
  ///
  /// In ja, this message translates to:
  /// **'このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。'**
  String get forkDevelopmentDisclosure;

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

  /// Use the original Japanese organization name in Japanese; its official English name is used in the English locale.
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

  /// Japanese formal organization name corresponding to the English subtitle. The Japanese selector continues to show its existing abbreviated label without a subtitle.
  ///
  /// In ja, this message translates to:
  /// **'全国珠算教育連盟'**
  String get zenshurenOrganizationSubtitle;

  /// Japanese formal organization name corresponding to the English subtitle. The Japanese selector continues to show its existing abbreviated label without a subtitle.
  ///
  /// In ja, this message translates to:
  /// **'日本珠算連盟'**
  String get nisshurenOrganizationSubtitle;

  /// Format an organization subtitle in parentheses beneath its primary selector label.
  ///
  /// In ja, this message translates to:
  /// **'（{subtitle}）'**
  String organizationSubtitleLine(String subtitle);

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

  /// ハンズフリー暗算の設定画面に表示する級位と団体。
  ///
  /// In ja, this message translates to:
  /// **'{grade} · {organization}'**
  String handsFreeAnzanKyuuiContext(String grade, String organization);

  /// 選択した各種目について、1題を表示する時間の目安。
  ///
  /// In ja, this message translates to:
  /// **'{subject}：{time}'**
  String handsFreeAnzanDurationPreview(String subject, String time);

  /// ハンズフリー暗算の問題を解いた後に表示する、書式付きの正答。
  ///
  /// In ja, this message translates to:
  /// **'答え：{answer}'**
  String handsFreeAnzanAnswer(String answer);

  /// No description provided for @handsFreeAnzanGenerationError.
  ///
  /// In ja, this message translates to:
  /// **'問題を作成できませんでした。このセッションを終了し、もう一度お試しください。'**
  String get handsFreeAnzanGenerationError;

  /// Countdown until the answer is revealed in hands-free Flash Anzan.
  ///
  /// In ja, this message translates to:
  /// **'{seconds}秒後に答えを表示'**
  String handsFreeRevealCountdown(int seconds);

  /// Countdown until the next hands-free Flash Anzan problem starts.
  ///
  /// In ja, this message translates to:
  /// **'{seconds}秒後に次の問題'**
  String handsFreeNextProblemCountdown(int seconds);

  /// Number of problem attempts completed in the current hands-free practice session.
  ///
  /// In ja, this message translates to:
  /// **'練習した問題数：{count}'**
  String handsFreeQuestionsCompleted(int count);

  /// Elapsed time in the current hands-free practice session.
  ///
  /// In ja, this message translates to:
  /// **'練習時間：{time}'**
  String handsFreePracticeTime(String time);

  /// No description provided for @handsFreeStop.
  ///
  /// In ja, this message translates to:
  /// **'ハンズフリーを終了'**
  String get handsFreeStop;

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

  /// No description provided for @reviewMistakesButton.
  ///
  /// In ja, this message translates to:
  /// **'間違えた問題を見る'**
  String get reviewMistakesButton;

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
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'ja':
      {
        switch (locale.scriptCode) {
          case 'Kana':
            return AppLocalizationsJaKana();
        }
        break;
      }
  }

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
