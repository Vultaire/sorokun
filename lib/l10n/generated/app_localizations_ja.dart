// Generated localization code for Sorokun.
// Localization resources updated by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'そろくん！';

  @override
  String get languageLabel => '言語 / Language';

  @override
  String get settingsTitle => 'アプリ設定';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get englishLanguage => 'English';

  @override
  String get englishTranslationDisclosure =>
      '英語インターフェースの翻訳にはLLMを使用しています。日本語が原文です。誤訳のご指摘を歓迎します。';

  @override
  String get keypadPosition => 'テンキーの配置';

  @override
  String get leftHanded => '左利き';

  @override
  String get rightHanded => '右利き';

  @override
  String get keypadLayout => 'キーレイアウト';

  @override
  String get screenBrightness => '画面の明るさ';

  @override
  String get automatic => '自動';

  @override
  String get theme => 'テーマ';

  @override
  String get color => 'カラー';

  @override
  String get homeCombinedLine1 => '総合';

  @override
  String get homeCombinedLine2 => '種目';

  @override
  String get homeSelectSubject => '種目を選ぶ';

  @override
  String get homeFlashLine1 => 'ﾌﾗｯｼｭ';

  @override
  String get homeFlashLine2 => '暗算';

  @override
  String get homeExam => '検定';

  @override
  String get homeFree => 'フリー';

  @override
  String get credits => 'クレジット';

  @override
  String get creditsDevelopment => '開発';

  @override
  String get developerRole => '開発者';

  @override
  String get originalSourceIntro => '元のそろくんのソースコードはこちらで公開されています：';

  @override
  String get forkSourceIntro => 'このフォークのソースコード：';

  @override
  String get forkModificationNotice =>
      '原作: Chet Lin。Vultaire による改変版です（2026-11-01）。読み上げ算と VOICEVOX を削除し、Web ビルド対応を行いました。';

  @override
  String get forkDevelopmentDisclosure =>
      'このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。';

  @override
  String get localizationUpdateNotice =>
      '日本語・English インターフェースのローカライズを2026-11-02に追加しました。';

  @override
  String get fontCredits => 'フォント';

  @override
  String get abacusBeadFont => 'そろばん玉のフォント';

  @override
  String get sorobanNumeralFont => '珠算の数字のフォント';

  @override
  String get license => 'ライセンス';

  @override
  String get noWarrantyLicenseNotice =>
      '本ソフトウェアは無保証です。GPL v3.0 の条件に従って再配布・改変できます。ライセンス全文は上記リンクから確認できます。';

  @override
  String get exitDialogTitle => '終了しますか？';

  @override
  String get exitDialogMessage => '提出するか、途中でやめるか選んでください。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get submit => '提出';

  @override
  String get quit => 'やめる';

  @override
  String get back => '戻る';

  @override
  String get combinedSubjectsTitle => '総合種目';

  @override
  String get organizationZenshuren => '全国珠算教育連盟';

  @override
  String get organizationNisshuren => '日本珠算連盟';

  @override
  String get organizationFlashAnzan => '日本ﾌﾗｯｼｭ暗算協会';

  @override
  String get selectorZenshuren => '全珠連';

  @override
  String get selectorNisshuren => '日珠連';

  @override
  String get selectorFlashAnzan => '協会';

  @override
  String get sorobanOrganizationGloss => '珠算の級位制度';

  @override
  String get flashAnzanOrganizationGloss => 'フラッシュ暗算の級位制度';

  @override
  String organizationGlossLine(String gloss) {
    return '（$gloss）';
  }

  @override
  String kyuGrade(int grade) {
    String _temp0 = intl.Intl.pluralLogic(
      grade,
      locale: localeName,
      other: '$grade級',
    );
    return '$_temp0';
  }

  @override
  String preKyuGrade(int grade) {
    return '準$grade級';
  }

  @override
  String get danGroupGrade => '段位';

  @override
  String danGrade(String grade) {
    String _temp0 = intl.Intl.selectLogic(grade, {
      '1': '初段',
      '2': '二段',
      '3': '三段',
      '4': '四段',
      '5': '五段',
      '6': '六段',
      '7': '七段',
      '8': '八段',
      '9': '九段',
      '10': '十段',
      'other': '$grade段',
    });
    return '$_temp0';
  }

  @override
  String get rankPreShodan => '準初段';

  @override
  String get rankShodan => '初段';

  @override
  String get rankPreNidan => '準二段';

  @override
  String get rankNidan => '二段';

  @override
  String get rankPreSandan => '準三段';

  @override
  String get rankSandan => '三段';

  @override
  String get rankPreYondan => '準四段';

  @override
  String get rankYondan => '四段';

  @override
  String get rankPreGodan => '準五段';

  @override
  String get rankGodan => '五段';

  @override
  String get rankPreRokudan => '準六段';

  @override
  String get rankRokudan => '六段';

  @override
  String get rankNanadan => '七段';

  @override
  String get rankHachidan => '八段';

  @override
  String get rankKudan => '九段';

  @override
  String get rankJudan => '十段';

  @override
  String get paperPractice => '練習';

  @override
  String get paperExam => '検定';

  @override
  String get mitoriZan => 'みとり算';

  @override
  String get division => 'わり算';

  @override
  String get multiplication => 'かけ算';

  @override
  String get mitoriAnzan => 'みとり暗算';

  @override
  String get divisionAnzan => 'わり暗算';

  @override
  String get multiplicationAnzan => 'かけ暗算';

  @override
  String get flashAnzanSubject => 'フラッシュ暗算';

  @override
  String gradeActivity(String grade, String activity) {
    return '$gradeの$activity';
  }

  @override
  String get start => 'スタート';

  @override
  String timeLimit(int minutes) {
    return '制限時間：$minutes分';
  }

  @override
  String problemCount(int count) {
    return '問題数：$count題';
  }

  @override
  String pointsEach(int points, int maximum) {
    return '各$points点 ($maximum点満点)';
  }

  @override
  String passingScore(int score) {
    return '合格点：$score点以上';
  }

  @override
  String oneProblemDigits(String range) {
    return '一題あたり$range字';
  }

  @override
  String methodDigits(String method, String range) {
    return '$methodあわせて$range桁';
  }

  @override
  String get jippou => '実法';

  @override
  String get houshou => '法商';

  @override
  String get mitorizanExplanation =>
      'Mitorizan (+/−)：縦に並んだ数を、足し算・引き算を交互に使って計算します。';

  @override
  String get flashExamTitle => 'フラッシュ暗算もぎ検定';

  @override
  String get flashFreeTitle => 'フラッシュ暗算フリー';

  @override
  String get flashDigitsLabel => '桁数';

  @override
  String get flashKuchiLabel => '口数';

  @override
  String digitsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '桁',
    );
    return '$_temp0';
  }

  @override
  String kuchiUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '口',
    );
    return '$_temp0';
  }

  @override
  String get secondsUnit => '秒';

  @override
  String flashAllProblems(int count) {
    return '全$count問 各10点';
  }

  @override
  String flashPassingScore(int score) {
    return '$score点で合格';
  }

  @override
  String get noCarry => 'くりあがりなし';

  @override
  String get displayInterval => '表示間隔';

  @override
  String get blankInterval => '消画間隔';

  @override
  String get millisecondsShort => 'ms';

  @override
  String get flashAnswerPrompt => '答えを記入してください。';

  @override
  String get repeatProblem => 'もう一回';

  @override
  String get nextProblem => '次の問題';

  @override
  String get grade => '採点';

  @override
  String get correct => '正解';

  @override
  String get incorrect => '不正解';

  @override
  String get answer => '答え';

  @override
  String get answerTime => '回答タイム';

  @override
  String answerTimeValue(String time) {
    return '$time秒';
  }

  @override
  String get time => 'タイム';

  @override
  String get reviewIncorrect => '間違えた問題を見る';

  @override
  String get tryAgain => 'もう一回挑戦する';

  @override
  String get returnHome => 'メインメニューに戻る';

  @override
  String get returnToSettings => '設定画面に戻る';

  @override
  String pointsOutOf(int maximum) {
    return '$maximum点満点';
  }

  @override
  String get pointsUnit => '点';

  @override
  String get passed => '合格';

  @override
  String get failed => '不合格';

  @override
  String get unknownLevelType => 'Unknown level type';

  @override
  String get timeUp => '時間切れ！';

  @override
  String get practiceComplete => '終了！';

  @override
  String get roundingDecimalNotice => '（注意） 小数第3位未満四捨五入。';

  @override
  String get roundingIntegerNotice => '（注意） 整数位未満四捨五入。';

  @override
  String get backspaceSemantics => '末尾の数字を削除（長押しですべて消去）';

  @override
  String get submitSemantics => '回答を送信';

  @override
  String get themeColorWheelSemantics => 'テーマカラーを選択';

  @override
  String get standardKeypadLayout => '標準のテンキー配列';

  @override
  String get telephoneKeypadLayout => '電話式のテンキー配列';

  @override
  String get increaseValue => '値を増やす';

  @override
  String get decreaseValue => '値を減らす';

  @override
  String get increaseTime => '表示時間を長くする';

  @override
  String get decreaseTime => '表示時間を短くする';
}
