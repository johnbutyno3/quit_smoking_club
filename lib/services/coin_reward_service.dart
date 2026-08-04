import '../config/coin_rules.dart';
import 'coin_service.dart';

/// Handles reward-related COIN operations.
/// Keeps reward rules away from general spending logic.
class CoinRewardService {
  CoinRewardService({CoinService? coinService})
      : _coinService = coinService ?? CoinService();

  final CoinService _coinService;

  Future<void> rewardDailyLogin() async {
    await _coinService.addCoin(
      CoinRules.dailyLoginReward,
      'daily_login',
    );
  }

  Future<void> rewardDailyPlan() async {
    await _coinService.addCoin(
      CoinRules.dailyPlanReward,
      'daily_plan_reward',
    );
  }
}
