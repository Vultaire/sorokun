// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/level_definitions.dart';

extension KyuuiLocalization on Kyuui {
  String localizedLabel(AppLocalizations l10n) {
    if (name.endsWith('dan')) return l10n.danGroupGrade;

    final gradeMatch = RegExp(r'(\d+)$').firstMatch(name);
    if (gradeMatch == null) return name;

    final grade = int.parse(gradeMatch.group(1)!);
    if (name.startsWith('zsd') || name.startsWith('kkd')) {
      return l10n.danGrade('$grade');
    }
    if (name.contains('j')) return l10n.preKyuGrade(grade);
    return l10n.kyuGrade(grade);
  }
}

extension DenominationLocalization on Denomination {
  String localizedName(AppLocalizations l10n) => switch (this) {
    Denomination.nisshou => l10n.organizationNisshuren,
    Denomination.zenshuren => l10n.organizationZenshuren,
    Denomination.kyoukai => l10n.organizationFlashAnzan,
  };
}

extension RankLabelLocalization on RankLabel {
  String localizedName(AppLocalizations l10n) => switch (this) {
    RankLabel.preShodan => l10n.rankPreShodan,
    RankLabel.shodan => l10n.rankShodan,
    RankLabel.preNidan => l10n.rankPreNidan,
    RankLabel.nidan => l10n.rankNidan,
    RankLabel.preSandan => l10n.rankPreSandan,
    RankLabel.sandan => l10n.rankSandan,
    RankLabel.preYondan => l10n.rankPreYondan,
    RankLabel.yondan => l10n.rankYondan,
    RankLabel.preGodan => l10n.rankPreGodan,
    RankLabel.godan => l10n.rankGodan,
    RankLabel.preRokudan => l10n.rankPreRokudan,
    RankLabel.rokudan => l10n.rankRokudan,
    RankLabel.nanadan => l10n.rankNanadan,
    RankLabel.hachidan => l10n.rankHachidan,
    RankLabel.kudan => l10n.rankKudan,
    RankLabel.judan => l10n.rankJudan,
  };
}
