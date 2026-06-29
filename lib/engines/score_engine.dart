import '../services/smoking_engine.dart';

class ScoreEngine {
  final SmokingEngine engine;

  ScoreEngine(this.engine);

  /// 獲取「今日」的戒菸表現分數 (基礎100分)
  int get score {
    int base = 100;

    // 1. 超抽扣分：每超抽一支扣 20 分
    base -= engine.overCount * 20;

    // 2. 每抽一支扣分：對齊你原本 engine 內就有的 totalSmoked，純整數不噴錯
    base -= engine.totalSmoked * 5;

    if (base < 0) return 0;
    return base;
  }

  /// 獲取今日表現評級 (A ~ D)
  String get grade {
    final s = score;
    if (s >= 80) return "A";
    if (s >= 60) return "B";
    if (s >= 40) return "C";
    return "D";
  }

  /// 總體計畫達成率評級
  String get overallProjectGrade {
    if (engine.plannedCount == 0) return "A+";
    double adherenceRate =
        (engine.plannedCount - engine.totalSmoked) / engine.plannedCount;

    if (adherenceRate >= 0.9) return "優秀 (A)";
    if (adherenceRate >= 0.7) return "良好 (B)";
    if (adherenceRate >= 0.5) return "尚可 (C)";
    return "需加油 (D)";
  }
}
