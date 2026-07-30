// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '戒菸俱樂部';

  @override
  String get settings => '設定';

  @override
  String get quitPlan => '戒菸計畫';

  @override
  String get welcomeMessage => '歡迎來到戒菸俱樂部！挑戰正在進行中。';

  @override
  String get hello => '你好';

  @override
  String get dailyCount => '每日抽菸量';

  @override
  String get cigarettePrice => '香菸單價';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get forum => '交流論壇';

  @override
  String get shop => '金幣商城';

  @override
  String get gameHub => '遊戲大廳';

  @override
  String get recordSmoke => '記錄抽菸';

  @override
  String get locked => '待解鎖';

  @override
  String get sos => 'SOS 求協助';

  @override
  String get smokedCount => '已抽支數';

  @override
  String get remaining => '剩餘額度';

  @override
  String get countdown => '距離下一次解鎖抽菸倒數';

  @override
  String get todaySchedule => '控菸今日排程表';

  @override
  String get createPost => '建立貼文';

  @override
  String get postName => '暱稱';

  @override
  String get postContent => '貼文內容';

  @override
  String get publish => '發布';

  @override
  String get myCoins => '我的 COIN';

  @override
  String get giftSent => '禮物送出成功';

  @override
  String get insufficientCoins => 'COIN 不足';

  @override
  String get postCreated => '貼文建立成功';

  @override
  String get anonymousUser => '匿名朋友';

  @override
  String get like => '讚';

  @override
  String get gift => '禮物';

  @override
  String get now => '剛剛';

  @override
  String minutesAgo(Object count) {
    return '$count 分鐘前';
  }

  @override
  String hoursAgo(Object count) {
    return '$count 小時前';
  }

  @override
  String daysAgo(Object count) {
    return '$count 天前';
  }

  @override
  String get emptyForum => '目前尚無論壇貼文，快建立第一篇吧！';

  @override
  String get sosPost => '求助文章';

  @override
  String get coinHistory => 'COIN 紀錄';

  @override
  String get currentBalance => '目前餘額';

  @override
  String get noTransactionHistory => '目前沒有交易紀錄';

  @override
  String get purchaseSuccess => '購買成功';

  @override
  String get premiumActivated => '高級會員已啟用';

  @override
  String get achievementDay1Title => '第一天';

  @override
  String get achievementDay1Description => '開始戒菸旅程';

  @override
  String get achievementDay7Title => '一週達成';

  @override
  String get achievementDay7Description => '連續戒菸 7 天';

  @override
  String get achievementDay30Title => '一個月達成';

  @override
  String get achievementDay30Description => '連續戒菸 30 天';

  @override
  String get achievementMoney1000Title => '省下 1000 元';

  @override
  String get achievementMoney1000Description => '累積省下 1000 元';

  @override
  String get achievementRecoveryTitle => '健康恢復';

  @override
  String get achievementRecoveryDescription => '完成第一個身體恢復里程碑';

  @override
  String get achievementDay7Progress => '尚未完成 7 天戒菸目標';

  @override
  String get achievementDay30Progress => '尚未完成 30 天戒菸目標';

  @override
  String get achievementMoney1000Progress => '尚未累積省下 1000 元';

  @override
  String get achievementRecoveryProgress => '尚未完成健康恢復階段';

  @override
  String get todayAchievement => '今日成就';

  @override
  String achievementCompleted(Object completed, Object total) {
    return '完成 $completed / $total';
  }

  @override
  String get quitProgress => '戒菸進度';

  @override
  String dayProgress(Object current, Object total) {
    return 'Day $current / $total';
  }

  @override
  String todayGoal(Object count) {
    return '今日目標：$count 支';
  }

  @override
  String smokedToday(Object count) {
    return '今日已抽：$count 支';
  }

  @override
  String remainingToday(Object count) {
    return '今日剩餘：$count 支';
  }

  @override
  String get startQuitTitle => '開始你的戒菸計畫';

  @override
  String get startQuitDescription => '建立專屬戒菸方案，追蹤你的健康變化，加入社群支持。';

  @override
  String get startPlan => '開始計畫';

  @override
  String get lifestyleTitle => '健康生活';

  @override
  String get exercise => '運動挑戰';

  @override
  String get healthKnowledge => '健康知識';

  @override
  String get relaxMusic => '放鬆音樂';

  @override
  String get ranking => '排行榜';

  @override
  String get coinBalanceTitle => '目前擁有金幣庫存';

  @override
  String get nextSmokeCountdown => '距離下一次解鎖抽菸倒數';

  @override
  String get sosHelp => 'SOS 求協助';

  @override
  String get recordSmoking => '記錄抽菸';

  @override
  String get notUnlocked => '尚未解鎖';

  @override
  String get coinShop => '金幣商城';

  @override
  String get todaySmokingSchedule => '控菸今日排程表';

  @override
  String get smoked => '已抽 ✓';

  @override
  String get notRecorded => '未記錄';

  @override
  String get remainingAmount => '剩餘額度';

  @override
  String get todaySaved => '今日省下';

  @override
  String get coinUnit => '金幣';

  @override
  String get forumCategoryAll => '全部';

  @override
  String get forumCategoryCraving => '菸癮犯了';

  @override
  String get forumCategoryStory => '戒菸心得';

  @override
  String get forumCategoryHealth => '健康交流';

  @override
  String get forumCategorySupport => '互相鼓勵';

  @override
  String get achievementSpending1000Title => '消費 1000 金幣';

  @override
  String get achievementSpending1000Description => '累積消費 1000 金幣';

  @override
  String get achievementSpending1000Progress => '尚未消費 1000 金幣';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '戒菸俱樂部';

  @override
  String get settings => '設定';

  @override
  String get quitPlan => '戒菸計畫';

  @override
  String get welcomeMessage => '歡迎來到戒菸俱樂部！挑戰正在進行中。';

  @override
  String get hello => '你好';

  @override
  String get dailyCount => '每日抽菸量';

  @override
  String get cigarettePrice => '香菸單價';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get forum => '交流論壇';

  @override
  String get shop => '金幣商城';

  @override
  String get gameHub => '遊戲大廳';

  @override
  String get recordSmoke => '記錄抽菸';

  @override
  String get locked => '待解鎖';

  @override
  String get sos => 'SOS 求協助';

  @override
  String get smokedCount => '已抽支數';

  @override
  String get remaining => '剩餘額度';

  @override
  String get countdown => '距離下一次解鎖抽菸倒數';

  @override
  String get todaySchedule => '控菸今日排程表';

  @override
  String get createPost => '建立貼文';

  @override
  String get postName => '暱稱';

  @override
  String get postContent => '貼文內容';

  @override
  String get publish => '發布';

  @override
  String get myCoins => '我的 COIN';

  @override
  String get giftSent => '禮物送出成功';

  @override
  String get insufficientCoins => 'COIN 不足';

  @override
  String get postCreated => '貼文建立成功';

  @override
  String get anonymousUser => '匿名朋友';

  @override
  String get like => '讚';

  @override
  String get gift => '禮物';

  @override
  String get now => '剛剛';

  @override
  String minutesAgo(Object count) {
    return '$count 分鐘前';
  }

  @override
  String hoursAgo(Object count) {
    return '$count 小時前';
  }

  @override
  String daysAgo(Object count) {
    return '$count 天前';
  }

  @override
  String get emptyForum => '目前尚無論壇貼文，快建立第一篇吧！';

  @override
  String get sosPost => '求助文章';

  @override
  String get coinHistory => 'COIN 紀錄';

  @override
  String get currentBalance => '目前餘額';

  @override
  String get noTransactionHistory => '目前沒有交易紀錄';

  @override
  String get purchaseSuccess => '購買成功';

  @override
  String get premiumActivated => '高級會員已啟用';

  @override
  String get achievementDay1Title => '第一天';

  @override
  String get achievementDay1Description => '開始戒菸旅程';

  @override
  String get achievementDay7Title => '一週達成';

  @override
  String get achievementDay7Description => '連續戒菸 7 天';

  @override
  String get achievementDay30Title => '一個月達成';

  @override
  String get achievementDay30Description => '連續戒菸 30 天';

  @override
  String get achievementMoney1000Title => '省下 1000 元';

  @override
  String get achievementMoney1000Description => '累積省下 1000 元';

  @override
  String get achievementRecoveryTitle => '健康恢復';

  @override
  String get achievementRecoveryDescription => '完成第一個身體恢復里程碑';

  @override
  String get achievementDay7Progress => '尚未完成 7 天戒菸目標';

  @override
  String get achievementDay30Progress => '尚未完成 30 天戒菸目標';

  @override
  String get achievementMoney1000Progress => '尚未累積省下 1000 元';

  @override
  String get achievementRecoveryProgress => '尚未完成健康恢復階段';

  @override
  String get todayAchievement => '今日成就';

  @override
  String achievementCompleted(Object completed, Object total) {
    return '完成 $completed / $total';
  }

  @override
  String get quitProgress => '戒菸進度';

  @override
  String dayProgress(Object current, Object total) {
    return 'Day $current / $total';
  }

  @override
  String todayGoal(Object count) {
    return '今日目標：$count 支';
  }

  @override
  String smokedToday(Object count) {
    return '今日已抽：$count 支';
  }

  @override
  String remainingToday(Object count) {
    return '今日剩餘：$count 支';
  }

  @override
  String get startQuitTitle => '開始你的戒菸計畫';

  @override
  String get startQuitDescription => '建立專屬戒菸方案，追蹤你的健康變化，加入社群支持。';

  @override
  String get startPlan => '開始計畫';

  @override
  String get lifestyleTitle => '健康生活';

  @override
  String get exercise => '運動挑戰';

  @override
  String get healthKnowledge => '健康知識';

  @override
  String get relaxMusic => '放鬆音樂';

  @override
  String get ranking => '排行榜';

  @override
  String get coinBalanceTitle => '目前擁有金幣庫存';

  @override
  String get nextSmokeCountdown => '距離下一次解鎖抽菸倒數';

  @override
  String get sosHelp => 'SOS 求協助';

  @override
  String get recordSmoking => '記錄抽菸';

  @override
  String get notUnlocked => '尚未解鎖';

  @override
  String get coinShop => '金幣商城';

  @override
  String get todaySmokingSchedule => '控菸今日排程表';

  @override
  String get smoked => '已抽 ✓';

  @override
  String get notRecorded => '未記錄';

  @override
  String get remainingAmount => '剩餘額度';

  @override
  String get todaySaved => '今日省下';

  @override
  String get coinUnit => '金幣';

  @override
  String get forumCategoryAll => '全部';

  @override
  String get forumCategoryCraving => '菸癮犯了';

  @override
  String get forumCategoryStory => '戒菸心得';

  @override
  String get forumCategoryHealth => '健康交流';

  @override
  String get forumCategorySupport => '互相鼓勵';

  @override
  String get achievementSpending1000Title => '消費 1000 金幣';

  @override
  String get achievementSpending1000Description => '累積消費 1000 金幣';

  @override
  String get achievementSpending1000Progress => '尚未消費 1000 金幣';
}
