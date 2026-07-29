import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/aloud_set.dart';
import 'package:soroban_app/problem_generation/mitori.dart';

List<String> moraListToJsonChunks({
  required List<Mora> moraList,
  required int moraPerSecond,
  required int msPerInterval,
  required int baseNote,
}) {
  const double frameStretchFactor = 1.6;
  final int framesPerMora =
      ((((1000 / moraPerSecond) * 93.75) / 1000) * frameStretchFactor).round();
  final int highNote = baseNote + 2;

  // Split into chunks of non-empty moras
  final List<List<Mora>> chunks = [];
  List<Mora> current = [];

  for (final mora in moraList) {
    if (mora.lyric.isEmpty) {
      if (current.isNotEmpty) {
        chunks.add(current);
        current = [];
      }
    } else {
      current.add(mora);
    }
  }
  if (current.isNotEmpty) chunks.add(current);

  return chunks.map((chunk) {
    final notes = <String>[];

    notes.add('    { "key": null, "frame_length": 5, "lyric": "" }');

    for (final mora in chunk) {
      final key = mora.isHighPitch ? highNote : baseNote;
      notes.add(
        '    { "key": $key, "frame_length": $framesPerMora, "lyric": "${mora.lyric}" }',
      );
    }

    notes.add('    { "key": null, "frame_length": 5, "lyric": "" }');

    return '{\n  "notes": [\n${notes.join(',\n')}\n  ]\n}';
  }).toList();
}

List<Mora> scoreMora(List<int> numbers) {
  final lyrics = scoreLyrics(numbers);
  final result = <Mora>[];
  bool currentHigh = false; // pitch of last word
  bool preserveAccent = true;

  // Helper to rebuild previous word as odaka
  void applyOdaka(int start, int end) {
    final length = end - start;
    if (length == 1) {
      result[start].isHighPitch = true;
    } else {
      // first mora keeps previous pitch
      result[start].isHighPitch = start == 0
          ? false
          : result[start - 1].isHighPitch;

      // all middle moras high
      for (int i = 1; i < length; i++) {
        result[start + i].isHighPitch = true;
      }

      // last mora low if ウ or ン
      final last = result[end - 1];
      if (last.lyric == 'ウ' || last.lyric == 'ン') {
        result[end - 1].isHighPitch = false;
        result[end - 2].isHighPitch = true;
      }
    }
  }

  int prevWordStart = 0;

  for (final word in lyrics) {
    final moras = word.lyrics;
    final accent = word.pitch;

    // --- ODAKA TRANSFORMATION ---
    if (accent == PitchAccent.odakaTransformation) {
      if (prevWordStart < result.length) {
        applyOdaka(prevWordStart, result.length);
      }
      // this word itself is all low
      result.addAll(moras.map((m) => Mora(lyric: m, isHighPitch: false)));
      currentHigh = false;
      preserveAccent = true;
      prevWordStart = result.length;
      continue;
    }

    // --- Determine downstep for numbered accents ---
    final downstep = switch (accent) {
      PitchAccent.zero => 0,
      PitchAccent.one => 1,
      PitchAccent.two => 2,
      PitchAccent.three => 3,
      PitchAccent.none => 0,
      _ => 0,
    };

    // --- Add moras ---
    for (int i = 0; i < moras.length; i++) {
      if (preserveAccent || currentHigh) {
        currentHigh = switch (accent) {
          PitchAccent.zero => i == 0 ? currentHigh : true,
          PitchAccent.one ||
          PitchAccent.two ||
          PitchAccent.three => i < downstep && (i > 0 || downstep == 1),
          PitchAccent.none => false,
          _ => true,
        };
      } else {
        currentHigh = false;
      }
      result.add(Mora(lyric: moras[i], isHighPitch: currentHigh));
      if (preserveAccent && word == NumberWord.ni || word == NumberWord.go) {
        currentHigh = true;
      }
    }

    // update state
    preserveAccent =
        word == NumberWord.none ||
            word == NumberWord.hiitewa ||
            word == NumberWord.kuwaete
        ? true
        : false;
    prevWordStart = result.length - moras.length;
  }

  return result;
}

List<LyricWord> scoreLyrics(List<int> numbers) {
  List<LyricWord> scoreLyrics = [];
  bool isNegative = false;
  scoreLyrics.add(NumberWord.none);
  for (final (i, n) in numbers.indexed) {
    if (n < 0 && !isNegative) {
      scoreLyrics.add(NumberWord.hiitewa);
      isNegative = true;
    }
    if (n > 0 && isNegative) {
      scoreLyrics.add(NumberWord.kuwaete);
      isNegative = false;
    }
    scoreLyrics.addAll(convertToKatakana(n.abs()));

    scoreLyrics.add(
      i < numbers.length - 1 ? MyriadPower.ennari : MyriadPower.endewa,
    );
    scoreLyrics.add(NumberWord.none);
  }
  return scoreLyrics;
}

class Mora {
  Mora({required this.lyric, required this.isHighPitch});
  final String lyric;
  bool isHighPitch;

  @override
  String toString() => lyric.isEmpty ? '\n' : (isHighPitch ? "$lyric'" : lyric);
}

enum PitchAccent { zero, one, two, three, odakaTransformation, none }

sealed class LyricWord {
  const LyricWord({required this.lyrics, required this.pitch});
  final List<String> lyrics;
  final PitchAccent pitch;
}

enum NumberWord implements LyricWord {
  // Single digits (1–9)
  ichi(lyrics: ['イ', 'チ'], pitch: .zero),
  ni(lyrics: ['ニ'], pitch: .zero), //technically odaka
  san(lyrics: ['サ', 'ン'], pitch: .zero),
  yon(lyrics: ['ヨ', 'ン'], pitch: .zero), //technically one
  go(lyrics: ['ゴ'], pitch: .zero), //technically odaka
  roku(lyrics: ['ロ', 'ク'], pitch: .zero), //technically odaka
  nana(lyrics: ['ナ', 'ナ'], pitch: .zero), //technically one
  hachi(lyrics: ['ハ', 'チ'], pitch: .zero), //technically odaka
  kyuu(lyrics: ['キュ', 'ウ'], pitch: .zero), //technically one

  // Tens
  juu(lyrics: ['ジュ', 'ウ'], pitch: .zero), //technically one
  nijuu(lyrics: ['ニ', 'ジュ', 'ウ'], pitch: .one),
  sanjuu(lyrics: ['サ', 'ン', 'ジュ', 'ウ'], pitch: .one),
  yonjuu(lyrics: ['ヨ', 'ン', 'ジュ', 'ウ'], pitch: .one),
  gojuu(lyrics: ['ゴ', 'ジュ', 'ウ'], pitch: .zero), //technically two
  rokujuu(lyrics: ['ロ', 'ク', 'ジュ', 'ウ'], pitch: .zero), //technically three
  nanajuu(lyrics: ['ナ', 'ナ', 'ジュ', 'ウ'], pitch: .zero), //technically two
  hachijuu(lyrics: ['ハ', 'チ', 'ジュ', 'ウ'], pitch: .zero), //technically three
  kyuujuu(lyrics: ['キュ', 'ウ', 'ジュ', 'ウ'], pitch: .one),

  // Hundreds
  hyaku(lyrics: ['ヒャ', 'ク'], pitch: .zero), //technically odaka
  nihyaku(lyrics: ['ニ', 'ヒャ', 'ク'], pitch: .zero), //technically odaka
  sanbyaku(lyrics: ['サ', 'ン', 'ビャ', 'ク'], pitch: .one),
  yonhyaku(lyrics: ['ヨ', 'ン', 'ヒャ', 'ク'], pitch: .one),
  gohyaku(lyrics: ['ゴ', 'ヒャ', 'ク'], pitch: .zero), //technically odaka
  roppyaku(lyrics: ['ロ', 'ッ', 'ピャ', 'ク'], pitch: .zero), //technically odaka
  nanahyaku(lyrics: ['ナ', 'ナ', 'ヒャ', 'ク'], pitch: .two),
  happyaku(lyrics: ['ハ', 'ッ', 'ピャ', 'ク'], pitch: .zero), //technically odaka
  kyuuhyaku(lyrics: ['キュ', 'ウ', 'ヒャ', 'ク'], pitch: .one),

  // Thousands
  sen(lyrics: ['セ', 'ン'], pitch: .one),
  nisen(lyrics: ['ニ', 'セ', 'ン'], pitch: .two),
  sanzen(lyrics: ['サ', 'ン', 'ゼ', 'ン'], pitch: .three),
  yonsen(lyrics: ['ヨ', 'ン', 'セ', 'ン'], pitch: .three),
  gosen(lyrics: ['ゴ', 'セ', 'ン'], pitch: .two),
  rokusen(lyrics: ['ロ', 'ク', 'セ', 'ン'], pitch: .three),
  nanasen(lyrics: ['ナ', 'ナ', 'セ', 'ン'], pitch: .three),
  hassen(lyrics: ['ハ', 'ッ', 'セ', 'ン'], pitch: .three),
  kyuusen(lyrics: ['キュ', 'ウ', 'セ', 'ン'], pitch: .three),

  // Add and Subtract
  kuwaete(lyrics: ['ク', 'ワ', 'エ', 'テ'], pitch: .two),
  hiitewa(lyrics: ['ヒ', 'イ', 'テ', 'ワ'], pitch: .one),
  none(lyrics: [''], pitch: .none);

  // Exceptions

  const NumberWord({required this.lyrics, required this.pitch});
  @override
  final List<String> lyrics;
  @override
  final PitchAccent pitch;
}

enum MyriadPower implements LyricWord {
  ennari(lyrics: ['エ', 'ン', 'ナ', 'リ'], pitch: .odakaTransformation),
  endewa(lyrics: ['エ', 'ン', 'デ', 'ワ'], pitch: .odakaTransformation),
  man(lyrics: ['マ', 'ン'], pitch: .one),
  oku(lyrics: ['オ', 'ク'], pitch: .odakaTransformation),
  icchou(lyrics: ['イ', 'ッ', 'チョ', 'ウ'], pitch: .one),
  hacchou(lyrics: ['ハ', 'ッ', 'チョ', 'ウ'], pitch: .one),
  jucchou(lyrics: ['ジュ', 'ッ', 'チョ', 'ウ'], pitch: .one),
  chou(lyrics: ['チョ', 'ウ'], pitch: .odakaTransformation),
  ikkei(lyrics: ['イ', 'ッ', 'ケ', 'イ'], pitch: .one),
  kei(lyrics: ['ケ', 'イ'], pitch: .odakaTransformation);

  const MyriadPower({required this.lyrics, required this.pitch});
  @override
  final List<String> lyrics;
  @override
  final PitchAccent pitch;
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
    (NumberWord.hachi, MyriadPower.chou): MyriadPower.hacchou,
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
  AloudProblemSet fullProblemSet = AloudProblemSet(spec: AloudLevel.zsd8);
  List<MitoriProblem> allProblems = fullProblemSet.mitoriProblemList;
  List<String> allAnswers = fullProblemSet.formattedAnswers;
}
