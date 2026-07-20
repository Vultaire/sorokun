enum Character {
  zundamon(
    singerId: 3003,
    baseNote: 62,
    keyRangeAdjustment: 2,
    displayString: 'ずんだもん',
  ),
  shikokuMetan(
    singerId: 3002,
    baseNote: 60,
    keyRangeAdjustment: 0,
    displayString: '四国めたん',
  ),
  kasukabeTsumugi(
    singerId: 3008,
    baseNote: 62,
    keyRangeAdjustment: 1,
    displayString: '春日部つむぎ',
  ),
  kuronoTakehiro(
    singerId: 3011,
    baseNote: 50,
    keyRangeAdjustment: -11,
    displayString: '玄野武宏',
  ),
  shirakamiKotarou(
    singerId: 3012,
    baseNote: 53,
    keyRangeAdjustment: -10,
    displayString: '白上虎太郎',
  ),
  aoyamaRyuusei(
    singerId: 3013,
    baseNote: 44,
    keyRangeAdjustment: -15,
    displayString: '青山龍星',
  ),
  meimeiHimari(
    singerId: 3014,
    baseNote: 58,
    keyRangeAdjustment: -2,
    displayString: '冥鳴ひまり',
  ),
  kyuushuuSora(
    singerId: 3015,
    baseNote: 60,
    keyRangeAdjustment: 0,
    displayString: '九州そら',
  ),
  mochikosan(
    singerId: 3079,
    baseNote: 60,
    keyRangeAdjustment: -1,
    displayString: 'もち子さん',
  ),
  kenzakiMesou(
    singerId: 3021,
    baseNote: 48,
    keyRangeAdjustment: -12,
    displayString: '剣崎雌雄',
  ),
  whiteCul(
    singerId: 3023,
    baseNote: 63,
    keyRangeAdjustment: 3,
    displayString: 'WhiteCUL',
  ),
  goki(
    singerId: 3027,
    baseNote: 58,
    keyRangeAdjustment: -2,
    displayString: '後鬼',
  ),
  no7(
    singerId: 3029,
    baseNote: 58,
    keyRangeAdjustment: -3,
    displayString: 'No.7',
  ),
  chibishikiJii(
    singerId: 3042,
    baseNote: 47,
    keyRangeAdjustment: -13,
    displayString: 'ちび式じい',
  ),
  oukaMiko(
    singerId: 3043,
    baseNote: 60,
    keyRangeAdjustment: 0,
    displayString: '櫻歌ミコ',
  ),
  sayo(
    singerId: 3046,
    baseNote: 61,
    keyRangeAdjustment: 0,
    displayString: 'SAYO',
  ),
  nurseRoboTypeT(
    singerId: 3047,
    baseNote: 61,
    keyRangeAdjustment: 1,
    displayString: 'ナースロボ＿タイプＴ',
  ),
  holyKnightBeniZakura(
    singerId: 3051,
    baseNote: 52,
    keyRangeAdjustment: -8,
    displayString: '†聖騎士 紅桜†',
  ),
  wakamatsuAkashi(
    singerId: 3051,
    baseNote: 47,
    keyRangeAdjustment: -14,
    displayString: '雀松朱司',
  ),
  kigashimaSourin(
    singerId: 3053,
    baseNote: 50,
    keyRangeAdjustment: -10,
    displayString: '麒ヶ島宗麟',
  ),
  harukaNana(
    singerId: 3054,
    baseNote: 63,
    keyRangeAdjustment: 5,
    displayString: '春歌ナナ',
  ),
  nekotsukaAru(
    singerId: 3055,
    baseNote: 55,
    keyRangeAdjustment: -4,
    displayString: '猫使アル',
  ),
  nekotsukaBii(
    singerId: 3058,
    baseNote: 63,
    keyRangeAdjustment: 5,
    displayString: '猫使ビィ',
  ),
  chuugokuUsagi(
    singerId: 3069,
    baseNote: 59,
    keyRangeAdjustment: 0,
    displayString: '中国うさぎ',
  ),
  aierutan(
    singerId: 3068,
    baseNote: 62,
    keyRangeAdjustment: 2,
    displayString: 'あいえるたん',
  ),
  manbetsuHanamaru(
    singerId: 3069,
    baseNote: 60,
    keyRangeAdjustment: 2,
    displayString: '満別花丸',
  ),
  kotoyomiNia(
    singerId: 3074,
    baseNote: 62,
    keyRangeAdjustment: 2,
    displayString: '琴詠ニア',
  );

  final int singerId;
  final int baseNote;
  final int keyRangeAdjustment;
  final String displayString;

  const Character({
    required this.singerId,
    required this.baseNote,
    required this.keyRangeAdjustment,
    required this.displayString,
  });
}
