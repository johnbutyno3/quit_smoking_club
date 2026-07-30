class CoinRules {
  // ==========================================
  // 初始 COIN
  // ==========================================

  /// 新會員首次加入贈送
  static const int newUserBonus = 20;

  // ==========================================
  // 每日收入
  // ==========================================

  /// 每日登入獎勵
  static const int dailyLoginReward = 10;

  /// 每日戒菸計畫完成獎勵
  static const int dailyPlanReward = 20;

  // ==========================================
  // 成就獎勵
  // ==========================================

  /// 戒菸第 1 天
  static const int achievementDay1 = 10;

  /// 戒菸第 7 天
  static const int achievementDay7 = 50;

  /// 戒菸第 30 天
  static const int achievementDay30 = 100;

  /// 省下金額達標
  static const int achievementMoney1000 = 100;

  /// 身體恢復階段完成
  static const int achievementRecovery = 50;

  // ==========================================
  // 論壇消費
  // ==========================================

  /// 建立論壇貼文
  static const int createPostCost = 50;

  /// 論壇留言
  static const int commentCost = 1;

  /// 論壇送禮
  static const int giftCost = 5;

  // ==========================================
  // 社群功能
  // ==========================================

  /// 建立私人聊天
  static const int privateChatCost = 20;

  // ==========================================
  // 商城測試 / 商品單位
  // 正式版接 IAP 後移至 ShopRules
  // ==========================================

  static const int smallCoinPack = 10;

  static const int mediumCoinPack = 50;

  static const int largeCoinPack = 100;

  // ==========================================
  // 消費成就
  // ==========================================

  /// 累積消費達標 COIN 數
  static const int spendingAchievementTarget = 1000;

  /// 達成後獎勵
  static const int spendingAchievementReward = 50;
}
