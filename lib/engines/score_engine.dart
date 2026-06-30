import '../services/smoking_engine.dart';

class ScoreEngine {
  // 修正 double 轉 int 類型錯誤與變數對齊
  int getDisplayScore(SmokingEngine engine) {
    final smoked = engine.totalSmoked;
    final planned = engine.state.plannedCount;
    if (planned == 0) return 100;

    final ratio = (planned - smoked) / planned;
    final score = (ratio * 100).clamp(0, 100);
    return score.toInt(); // 💡 完美修正 double 轉 int 衝突
  }
}
