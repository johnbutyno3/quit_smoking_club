import 'score_engine.dart';
import '../services/smoking_engine.dart';

class RewardEngine {
  final ScoreEngine _scoreEngine = ScoreEngine();

  // 對齊最新 ScoreEngine 方法名稱，修復第一個紅色錯誤
  int calculateRewardCoins(SmokingEngine engine) {
    final currentScore = _scoreEngine.getDisplayScore(engine);
    if (currentScore > 80) return 10;
    if (currentScore > 50) return 5;
    return 0;
  }
}
