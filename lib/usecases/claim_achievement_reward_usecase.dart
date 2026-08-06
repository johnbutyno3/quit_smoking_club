import '../engines/achievement_engine.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/storage_service.dart';

class ClaimAchievementRewardUseCase {
  final CoinRepository coinRepository;

  ClaimAchievementRewardUseCase({CoinRepository? coinRepository})
    : coinRepository = coinRepository ?? CoinRepository();

  Future<void> execute(AchievementEngine engine) async {
    final loginStreak = await StorageService.getLoginStreak();
    if (loginStreak <= 0) {
      return;
    }

    final claimed = await StorageService.getClaimedAchievements();

    for (final achievement in engine.achievements) {
      if (!achievement.unlocked || claimed.contains(achievement.id)) {
        continue;
      }

      final reward = engine.rewardForAchievement(achievement.id);
      if (reward <= 0) {
        continue;
      }

      await coinRepository.addCoin(reward, 'achievement_${achievement.id}');
      await StorageService.saveClaimedAchievement(achievement.id);
    }
  }
}
