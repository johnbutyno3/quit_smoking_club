import 'smoking_engine.dart';

class InterventionEngine {
  // 對齊最新動態抽菸支數防禦
  String getAdvice(SmokingEngine engine) {
    final smoked = engine.totalSmoked;
    final planned = engine.state.plannedCount;
    if (smoked > planned) {
      return "🚨 已超過今日額度！請立刻進入求救緩解艙！";
    }
    return "🟢 目前控菸進度良好，繼續保持！";
  }
}
