import '../config/coin_rules.dart';
import '../repositories/coin/coin_repository.dart';

/// Handles reward-related COIN operations.
/// Keeps reward rules away from general spending logic.
class CoinRewardService {
  CoinRewardService({CoinRepository? coinRepository})
    : _coinRepository = coinRepository ?? CoinRepository();

  final CoinRepository _coinRepository;

  Future<void> rewardDailyLogin() async {
    await _coinRepository.addCoin(CoinRules.dailyLoginReward, 'daily_login');
  }

  Future<void> rewardDailyPlan() async {
    await _coinRepository.addCoin(
      CoinRules.dailyPlanReward,
      'daily_plan_reward',
    );
  }
}
