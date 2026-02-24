import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/mitori.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';

List<LyricWord> scoreLyrics(List<int> numbers) {
  List<LyricWord> scoreLyrics = [];
  for (final (i, n) in numbers.indexed) {
    bool isNegative = false;
    if (n < 0) {
      scoreLyrics.add(NumberWord.hiitewa);
      isNegative = true;
    }
    if (n > 0 || isNegative) {
      scoreLyrics.add(NumberWord.kuwaete);
      isNegative = false;
    }
    scoreLyrics.addAll(convertToKatakana(n));

    scoreLyrics.add(
      i < numbers.length - 1 ? MyriadPower.ennari : MyriadPower.endewa,
    );
  }
  return scoreLyrics;
}

enum Pitch { zero, one, two, three, odaka, odakaTransformation }

sealed class LyricWord {
  const LyricWord({required this.lyric, required this.pitch});
  final List<String> lyric;
  final Pitch pitch;
}

enum NumberWord implements LyricWord {
  // Single digits (1–9)
  ichi(lyric: ['イ', 'チ'], pitch: .zero),
  ni(lyric: ['ニ'], pitch: .odaka),
  san(lyric: ['サ', 'ン'], pitch: .zero),
  yon(lyric: ['ヨ', 'ン'], pitch: .one),
  go(lyric: ['ゴ'], pitch: .odaka),
  roku(lyric: ['ロ', 'ク'], pitch: .odaka),
  nana(lyric: ['ナ', 'ナ'], pitch: .one),
  hachi(lyric: ['ハ', 'チ'], pitch: .odaka),
  kyuu(lyric: ['キュ', 'ウ'], pitch: .one),

  // Tens (10–90)
  juu(lyric: ['ジュ', 'ウ'], pitch: .zero), //technically one
  nijuu(lyric: ['ニ', 'ジュ', 'ウ'], pitch: .one),
  sanjuu(lyric: ['サ', 'ン', 'ジュ', 'ウ'], pitch: .one),
  yonjuu(lyric: ['ヨ', 'ン', 'ジュ', 'ウ'], pitch: .one),
  gojuu(lyric: ['ゴ', 'ジュ', 'ウ'], pitch: .zero), //technically two
  rokujuu(lyric: ['ロ', 'ク', 'ジュ', 'ウ'], pitch: .zero), //technically three
  nanajuu(lyric: ['ナ', 'ナ', 'ジュ', 'ウ'], pitch: .zero), //technically two
  hachijuu(lyric: ['ハ', 'チ', 'ジュ', 'ウ'], pitch: .zero), //technically three
  kyuujuu(lyric: ['キュ', 'ウ', 'ジュ', 'ウ'], pitch: .one),

  // Hundreds (100–900)
  hyaku(lyric: ['ヒャ', 'ク'], pitch: .zero), //technically odaka
  nihyaku(lyric: ['ニ', 'ヒャ', 'ク'], pitch: .zero), //technically odaka
  sanbyaku(lyric: ['サ', 'ン', 'ビャ', 'ク'], pitch: .one),
  yonhyaku(lyric: ['ヨ', 'ン', 'ヒャ', 'ク'], pitch: .one),
  gohyaku(lyric: ['ゴ', 'ヒャ', 'ク'], pitch: .zero), //technically odaka
  roppyaku(lyric: ['ロ', 'ッ', 'ピャ', 'ク'], pitch: .zero), //technically odaka
  nanahyaku(lyric: ['ナ', 'ナ', 'ヒャ', 'ク'], pitch: .two),
  happyaku(lyric: ['ハ', 'ッ', 'ピャ', 'ク'], pitch: .zero), //technically odaka
  kyuuhyaku(lyric: ['キュ', 'ウ', 'ヒャ', 'ク'], pitch: .one),

  // Thousands (1000–9000)
  sen(lyric: ['セ', 'ン'], pitch: .one),
  nisen(lyric: ['ニ', 'セ', 'ン'], pitch: .two),
  sanzen(lyric: ['サ', 'ン', 'ゼ', 'ン'], pitch: .three),
  yonsen(lyric: ['ヨ', 'ン', 'セ', 'ン'], pitch: .three),
  gosen(lyric: ['ゴ', 'セ', 'ン'], pitch: .two),
  rokusen(lyric: ['ロ', 'ク', 'セ', 'ン'], pitch: .three),
  nanasen(lyric: ['ナ', 'ナ', 'セ', 'ン'], pitch: .three),
  hassen(lyric: ['ハ', 'ッ', 'セ', 'ン'], pitch: .three),
  kyuusen(lyric: ['キュ', 'ウ', 'セ', 'ン'], pitch: .three),

  // Add and Subtract
  kuwaete(lyric: ['ク', 'ワ', 'エ', 'テ'], pitch: .two),
  hiitewa(lyric: ['ヒ', 'イ', 'テ', 'ワ'], pitch: .one);

  // Exceptions

  const NumberWord({required this.lyric, required this.pitch});
  @override
  final List<String> lyric;
  @override
  final Pitch pitch;
}

enum MyriadPower implements LyricWord {
  ennari(lyric: ['エ', 'ン', 'ナ', 'リ'], pitch: .odakaTransformation),
  endewa(lyric: ['エ', 'ン', 'デ', 'ワ'], pitch: .odakaTransformation),
  man(lyric: ['マ', 'ン'], pitch: .one),
  oku(lyric: ['オ', 'ク'], pitch: .odakaTransformation),
  icchou(lyric: ['イ', 'ッ', 'チョ', 'ウ'], pitch: .one),
  jucchou(lyric: ['ジュ', 'ッ', 'チョ', 'ウ'], pitch: .one),
  chou(lyric: ['チョ', 'ウ'], pitch: .odakaTransformation),
  ikkei(lyric: ['イ', 'ッ', 'ケ', 'イ'], pitch: .one),
  kei(lyric: ['ケ', 'イ'], pitch: .odakaTransformation);

  const MyriadPower({required this.lyric, required this.pitch});
  @override
  final List<String> lyric;
  @override
  final Pitch pitch;
}

List<LyricWord> convertToKatakana(int n) {
  const Map<(String, int), NumberWord> digitPlaceToWord = {
    // Ones
    ('1', 1): NumberWord.ichi,
    ('2', 1): NumberWord.ni,
    ('3', 1): NumberWord.san,
    ('4', 1): NumberWord.yon,
    ('5', 1): NumberWord.go,
    ('6', 1): NumberWord.roku,
    ('7', 1): NumberWord.nana,
    ('8', 1): NumberWord.hachi,
    ('9', 1): NumberWord.kyuu,
    // Tens
    ('1', 2): NumberWord.juu,
    ('2', 2): NumberWord.nijuu,
    ('3', 2): NumberWord.sanjuu,
    ('4', 2): NumberWord.yonjuu,
    ('5', 2): NumberWord.gojuu,
    ('6', 2): NumberWord.rokujuu,
    ('7', 2): NumberWord.nanajuu,
    ('8', 2): NumberWord.hachijuu,
    ('9', 2): NumberWord.kyuujuu,
    // Hundreds
    ('1', 3): NumberWord.hyaku,
    ('2', 3): NumberWord.nihyaku,
    ('3', 3): NumberWord.sanbyaku,
    ('4', 3): NumberWord.yonhyaku,
    ('5', 3): NumberWord.gohyaku,
    ('6', 3): NumberWord.roppyaku,
    ('7', 3): NumberWord.nanahyaku,
    ('8', 3): NumberWord.happyaku,
    ('9', 3): NumberWord.kyuuhyaku,
    // Thousands
    ('1', 4): NumberWord.sen,
    ('2', 4): NumberWord.nisen,
    ('3', 4): NumberWord.sanzen,
    ('4', 4): NumberWord.yonsen,
    ('5', 4): NumberWord.gosen,
    ('6', 4): NumberWord.rokusen,
    ('7', 4): NumberWord.nanasen,
    ('8', 4): NumberWord.hassen,
    ('9', 4): NumberWord.kyuusen,
  };

  const Map<int, MyriadPower?> groupName = {
    0: null,
    1: MyriadPower.man,
    2: MyriadPower.oku,
    3: MyriadPower.chou,
    4: MyriadPower.kei,
  };

  final str = n.toString();
  final List<LyricWord> result = [];

  final List<String> myriads = [];
  for (int i = str.length; i > 0; i -= 4) {
    myriads.insert(0, str.substring((i - 4).clamp(0, str.length), i));
  }

  for (int g = 0; g < myriads.length; g++) {
    final myriadGroup = myriads[g];
    final groupIndex = myriads.length - 1 - g;

    if (!myriadGroup.contains(RegExp(r'[1-9]'))) continue;

    for (int i = 0; i < myriadGroup.length; i++) {
      final char = myriadGroup[i];
      if (char == '0') continue;
      final place = myriadGroup.length - i;
      result.add(digitPlaceToWord[(char, place)]!);
    }

    final MyriadPower? marker = groupName[groupIndex];
    if (marker != null) result.add(marker);
  }
  if (myriads.length > 3) {
    return myriadAbbreviation(result);
  } else {
    return result;
  }
}

List<LyricWord> myriadAbbreviation(List<LyricWord> words) {
  const rules = {
    (NumberWord.ichi, MyriadPower.chou): MyriadPower.icchou,
    (NumberWord.juu, MyriadPower.chou): MyriadPower.jucchou,
    (NumberWord.ichi, MyriadPower.kei): MyriadPower.ikkei,
  };

  final result = <LyricWord>[];

  for (int i = 0; i < words.length; i++) {
    if (i < words.length - 1) {
      final pair = (words[i], words[i + 1]);
      final replacement = rules[pair];
      if (replacement != null) {
        result.add(replacement);
        i++; // skip next
        continue;
      }
    }
    result.add(words[i]);
  }

  return result;
}

void main() {
  MitoriProblemSet fullProblemSet = MitoriProblemSet(
    level: ComplexMitoriLevel.zsk5,
  );
  List<MitoriProblem> allProblems = fullProblemSet.unformattedProblems;
  List<String> allAnswers = fullProblemSet.formattedAnswers;

  print(convertToKatakana(21012085826347));
}
