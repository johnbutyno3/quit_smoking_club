import '../../l10n/app_localizations.dart';
import '../../engines/achievement_engine.dart';

class AchievementLocalizer {
  static String title(Achievement achievement, AppLocalizations l10n) {
    switch (achievement.titleKey) {
      case 'achievementDay1Title':
        return l10n.achievementDay1Title;

      case 'achievementDay7Title':
        return l10n.achievementDay7Title;

      case 'achievementDay30Title':
        return l10n.achievementDay30Title;

      case 'achievementSpending1000Title':
        return l10n.achievementSpending1000Title;

      case 'achievementRecoveryTitle':
        return l10n.achievementRecoveryTitle;

      default:
        return achievement.titleKey;
    }
  }

  static String progress(Achievement achievement, AppLocalizations l10n) {
    switch (achievement.progressKey) {
      case 'achievementDay7Progress':
        return l10n.achievementDay7Progress;

      case 'achievementDay30Progress':
        return l10n.achievementDay30Progress;

      case 'achievementSpending1000Progress':
        return l10n.achievementSpending1000Progress;

      case 'achievementRecoveryProgress':
        return l10n.achievementRecoveryProgress;

      default:
        return '';
    }
  }

  static String description(Achievement achievement, AppLocalizations l10n) {
    switch (achievement.descriptionKey) {
      case 'achievementDay1Description':
        return l10n.achievementDay1Description;

      case 'achievementDay7Description':
        return l10n.achievementDay7Description;

      case 'achievementDay30Description':
        return l10n.achievementDay30Description;

      case 'achievementSpending1000Description':
        return l10n.achievementSpending1000Description;

      case 'achievementRecoveryDescription':
        return l10n.achievementRecoveryDescription;

      default:
        return achievement.descriptionKey;
    }
  }
}
