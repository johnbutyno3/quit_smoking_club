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
  String get quitPlanPageTitle => '戒菸計畫';

  @override
  String get quitPlanDailyCigarettes => '每日抽菸數';

  @override
  String get quitPlanPricePerPack => '每包價格';

  @override
  String get quitPlanCigarettesPerPack => '每包支數';

  @override
  String get quitPlanDays => '戒菸天數';

  @override
  String get quitPlanGenerateButton => '產生戒菸計畫';

  @override
  String quitPlanEstimatedSavings(Object saving) {
    return '預估節省：$saving 元';
  }

  @override
  String quitPlanDayLabel(Object day) {
    return '第 $day 天';
  }

  @override
  String plannedCigarettes(Object count) {
    return '🚬 $count 支';
  }

  @override
  String get previousStep => '上一步';

  @override
  String get nextStep => '下一步';

  @override
  String usernameAlreadyUsed(Object name) {
    return '「$name」已被使用，請換一個';
  }

  @override
  String usernameAlreadyUsedPleaseEdit(Object name) {
    return '「$name」已被使用，請返回修改';
  }

  @override
  String get usernameStartQuitJourney => '開始戒菸之旅 🚀';

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
  String dailySignInNotification(Object rank) {
    return '📆 跨天簽到：您目前為 [$rank]';
  }

  @override
  String dailyRewardNotification(Object reward) {
    return '💰 系統已自動發放今日福利 $reward 金幣！';
  }

  @override
  String get smokingUnlockNotification => '🔔 控菸時間已到！新一輪配額已解鎖，您今天已成功少抽 2 支菸！';

  @override
  String get smokeSuccessMessage => '🎉 你太棒了，少抽一支菸！';

  @override
  String get cravingWarningMessage => '🚨 警告：使用者菸癮犯了！已通知好友！';

  @override
  String get friendEncouragementMessage => '💬 好友小明：堅持住！快進入下方的緩解艙！';

  @override
  String get cravingReliefChamberTitle => '🚨 菸癮危機緩解艙';

  @override
  String get mitigationTileMedical => '1. 醫學常識 (內建戒菸文章)';

  @override
  String get mitigationTileShortJokes => '2. 極短篇笑話 (短文小故事)';

  @override
  String get readingArticleOfflineLabel => '閱讀文章（下載後可離線閱讀）';

  @override
  String get youtubeVideoLabel => '3. YouTube影片 (看一下影片)';

  @override
  String get musicLinkLabel => '4. 音樂連結 (聽一下音樂)';

  @override
  String cigarettesCount(Object count) {
    return '$count 支';
  }

  @override
  String currencyAmount(Object amount) {
    return '$amount 元';
  }

  @override
  String get todaySaved => '今日省下';

  @override
  String get smoked => '已抽 ✓';

  @override
  String get notRecorded => '未記錄';

  @override
  String get remainingAmount => '剩餘額度';

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

  @override
  String get readingTitle => '閱讀文章';

  @override
  String get readingEmpty => '目前沒有可閱讀的文章。';

  @override
  String get refresh => '重新整理';

  @override
  String get readingCoinInsufficient => 'COIN 不足，無法下載這篇文章。';

  @override
  String get downloadFailed => '下載失敗，請稍後再試。';

  @override
  String get downloadAndRead => '下載並閱讀';

  @override
  String get contentManagementTitle => '內容管理';

  @override
  String get contentManagementAdd => '新增內容';

  @override
  String get contentManagementNoData => '無內容資料';

  @override
  String get contentManagementEmpty => '目前無資料';

  @override
  String get contentManagementEditTitle => '編輯內容';

  @override
  String contentManagementCategory(Object category) {
    return '分類：$category';
  }

  @override
  String get contentManagementLanguageCode => '語言代碼 (zh-tw / en / es / all)';

  @override
  String get contentManagementTitleLabel => '標題';

  @override
  String get contentManagementContentLabel => '內容';

  @override
  String get contentManagementLinkLabel => '連結網址';

  @override
  String get loginEmail => '電子郵件';

  @override
  String get loginPassword => '密碼';

  @override
  String get loginWithEmail => '信箱登入';

  @override
  String get loginWithGoogle => '使用 Google 帳號登入';

  @override
  String get loginPasswordMinLength => '密碼 (至少6碼)';

  @override
  String get registerNewAccount => '註冊新帳號';

  @override
  String get enterValidEmail => '請輸入正確的電子郵件';

  @override
  String get passwordMinLengthError => '密碼至少需要 6 個字元';

  @override
  String get emailAlreadyRegistered => '此電子郵件已被註冊，請直接登入';

  @override
  String get weakPassword => '密碼強度不足';

  @override
  String get invalidEmailFormat => '電子郵件格式不正確';

  @override
  String get registrationFailed => '註冊失敗，請稍後再試';

  @override
  String get fillEmailAndPassword => '請填寫電子郵件與密碼';

  @override
  String get invalidEmailOrPassword => '電子郵件或密碼不正確';

  @override
  String get tooManyAttempts => '嘗試次數過多，請稍後再試';

  @override
  String get loginFailed => '登入失敗，請稍後再試';

  @override
  String loginFailedWithError(Object error) {
    return '登入失敗：$error';
  }

  @override
  String get externalLinkInvalidFormat => '連結格式無效，顯示內建內容。';

  @override
  String get externalLinkOpenTimeout => '外部連結無法在 10 秒內開啟；改為顯示內建內容。';

  @override
  String get externalLinkOpenFailed => '無法開啟外部連結，改為顯示內建內容。';

  @override
  String get onlineGameRecommendation => '🌐 推薦線上遊戲';

  @override
  String get nextTip => '下一則提示';

  @override
  String get randomTip => '隨機';

  @override
  String get successfullySurvivedButton => '🟢 我撐過了！';

  @override
  String get cravingTip => '💡 小提醒：當菸癮來襲時，深呼吸 3 次可幫助緩解不適！';

  @override
  String get offlineBuiltInLabel => '✅ 完全內建 · 離線可玩';

  @override
  String get motivationalQuote1 => '每一支沒抽的菸，都是你重新掌控生活的勝利！';

  @override
  String get motivationalQuote2 => '深呼吸！這口新鮮空氣比尼古丁更強大！';

  @override
  String get motivationalQuote3 => '菸癮通常只會持續約 3 分鐘，撐過就算贏！';

  @override
  String get motivationalQuote4 => '你省下的不是錢，而是和家人相處的時間！';

  @override
  String get motivationalQuote5 => '你比自己想像的還要強！';

  @override
  String get loginAppSloganTitle => '戒菸好習慣';

  @override
  String get loginAppSloganSubtitle => '陪你每天一步一步戒菸';

  @override
  String get loginTabSignIn => '登入';

  @override
  String get loginTabRegister => '註冊';

  @override
  String get introSlide1Title => '開始你的戒菸之旅';

  @override
  String get introSlide1Desc => '科學化的戒菸計畫，幫助你一步一步減少菸量，直到完全戒斷。每一天都是勝利。';

  @override
  String get introSlide2Title => '個人化排程計畫';

  @override
  String get introSlide2Desc => '根據你的抽菸習慣，系統自動生成最適合你的戒菸時間表，並即時追蹤進度。';

  @override
  String get introSlide3Title => '社群互助，不再孤單';

  @override
  String get introSlide3Desc => '加入戒菸社群，與同道人互相支持鼓勵。菸癮犯了？立即求救，大家都在。';

  @override
  String get introSkip => '略過';

  @override
  String get introGetStarted => '開始使用';

  @override
  String get introNext => '下一頁 ›';

  @override
  String get rankingGlobalTitle => '全球排行榜';

  @override
  String rankingQuitDays(Object days) {
    return '戒菸 $days 天';
  }

  @override
  String readingWaitSeconds(Object seconds) {
    return '請再閱讀 $seconds 秒後繼續。';
  }

  @override
  String get readingCompletedArticle => '已完成這篇文章。';

  @override
  String readingChapterProgress(Object current, Object total) {
    return '第 $current 章／共 $total 章';
  }

  @override
  String get readingCanContinue => '可以繼續下一章';

  @override
  String readingMinSeconds(Object seconds) {
    return '請閱讀至少 $seconds 秒';
  }

  @override
  String get readingFinish => '完成閱讀';

  @override
  String get readingContinueNextChapter => '繼續下一章';

  @override
  String shopBuyCoins(Object amount) {
    return '購買 $amount COIN';
  }

  @override
  String get shopCreateForumPost => '建立論壇貼文 (-30 COIN)';

  @override
  String get shopVipActive => 'VIP 已啟用';

  @override
  String get shopPremium => '高級會員';

  @override
  String get shopVip => 'VIP';

  @override
  String get forumInsufficientCoinsToGift => '金幣不足，請前往金幣商城。';

  @override
  String get forumCreatePostTitle => '創建新貼文';

  @override
  String get forumNeedCoinsToCreatePost => 'COIN 不足，請前往商城購買 COIN';

  @override
  String get forumCommentSuccessCostOneCoin => '留言成功，扣除 1 COIN';

  @override
  String get forumCommentFailed => '留言失敗';

  @override
  String get forumCommentNeedsOneCoin => '留言需要 1 COIN';

  @override
  String get forumWatchAdComment => '觀看廣告留言';

  @override
  String get forumGoToCoinShop => '前往 COIN 商城';

  @override
  String get forumBuyCoin => '購買 COIN';

  @override
  String get forumWatchingAd => '觀看廣告中...';

  @override
  String get forumPostDetailTitle => '文章詳情';

  @override
  String get forumComments => '留言';

  @override
  String get forumNoComments => '目前沒有留言';

  @override
  String get forumCommentHint => '輸入留言...';

  @override
  String get scheduleTitle => '戒菸排程';

  @override
  String scheduleDayRemaining(Object elapsed, Object remaining) {
    return '第 $elapsed 天 · 剩 $remaining 天';
  }

  @override
  String get scheduleWeeklyView => '本週視圖';

  @override
  String get scheduleMonthlyView => '月視圖';

  @override
  String get scheduleHeaderDay => '天數';

  @override
  String get scheduleHeaderDate => '日期';

  @override
  String get scheduleHeaderPlanned => '計畫';

  @override
  String get scheduleHeaderActual => '實際';

  @override
  String get scheduleLegendOnTarget => '達標';

  @override
  String get scheduleLegendOverTarget => '超標';

  @override
  String get scheduleLegendFutureOrEmpty => '未來/無記錄';

  @override
  String get setupBasicInfo => '基本資料';

  @override
  String get setupEdit => '編輯';

  @override
  String get setupNone => '無';

  @override
  String get setupAgeLabel => '年齡';

  @override
  String get setupSmokingYearsLabel => '菸齡';

  @override
  String setupYearsOld(Object value) {
    return '$value 歲';
  }

  @override
  String setupYearsValue(Object value) {
    return '$value 年';
  }

  @override
  String setupCigarettesPerDay(Object value) {
    return '$value 支';
  }

  @override
  String setupPricePerPack(Object value) {
    return '$value 元／包';
  }

  @override
  String get setupPlanDays => '計畫天數';

  @override
  String setupPlanDaysValue(Object days) {
    return '$days 天';
  }

  @override
  String get setupFirstSmokeTime => '第一支菸時間';

  @override
  String get setupLastSmokeTime => '最後一支菸時間';

  @override
  String get setupViewSchedule => '查詢戒菸行程';

  @override
  String get setupContentManagement => '內容管理後台';

  @override
  String get setupConfirmSignOut => '確認登出';

  @override
  String get setupSignOutConfirmMessage => '登出後資料將保留在雲端，下次登入即可同步回來。';

  @override
  String get setupSignOut => '登出';

  @override
  String get setupSignOutAccount => '登出帳號';

  @override
  String get setupEditBasicInfo => '編輯基本資料';

  @override
  String get setupSmokingYearsWithYear => '菸齡 (年)';

  @override
  String get setupDailyCigarettes => '每日吸菸支數';

  @override
  String get setupPricePerPackLabel => '香菸單價（每包）';

  @override
  String setupFirstSmokeWithTime(Object time) {
    return '第一支菸\n$time';
  }

  @override
  String setupLastSmokeWithTime(Object time) {
    return '最後一支菸\n$time';
  }

  @override
  String get setupPlanDaysLabel => '計畫天數：';

  @override
  String setupDaysCompact(Object days) {
    return '$days天';
  }

  @override
  String setupFormatError(Object error) {
    return '格式錯誤: $error';
  }

  @override
  String get onboardingNameRequired => '⚠️ 請輸入您的暱稱喔！';

  @override
  String get onboardingFeature1Title => '🌿 醫學級動態控菸排程';

  @override
  String get onboardingFeature1Desc =>
      '打破傳統死板定時器！隨時根據您的真實按下時間，動態向後延遲 90 分鐘計算。沒抽菸絕不鎖定，時間過期自動褪色變暗，輔以打勾連動實抽狀態！';

  @override
  String get onboardingFeature2Title => '👑 高級黑金代幣商城';

  @override
  String get onboardingFeature2Desc =>
      '內建階梯式寶箱充值包與奢華黑金漸層 VIP 會員卡。跨天 00:00 系統全自動識別一般/高級會員並智能補發福利金幣，完美串聯商務閉環！';

  @override
  String get onboardingFeature3Title => '🧡 高顏值卡片流交流論壇';

  @override
  String get onboardingFeature3Desc =>
      '首創社群卡片流 Social Feed。使用者遇到菸癮危機按下 SOS 時，系統秒自動同步發布即時求救貼文，大家可以花費 5 金幣送出禮物留言打氣！';

  @override
  String get onboardingWelcome => '歡迎加入戒菸俱樂部，重獲健康生活';

  @override
  String get onboardingCreateProfile => '✍️ 首次建立戒菸個人檔案';

  @override
  String get onboardingNicknameInput => '請輸入您的暱稱';

  @override
  String get onboardingDailyTarget => '今日目標控菸支數 (預設5支)';

  @override
  String get onboardingStartJourney => '開啟戒菸健康之旅';

  @override
  String get homePremiumMember => '高級會員';

  @override
  String get homeRegularMember => '一般會員';

  @override
  String get gameHubBuiltInMiniGames => '內建小遊戲';

  @override
  String get forumGoToForumLobby => '前往論壇大廳';

  @override
  String get nickname_empty => '昵称不能为空';

  @override
  String get nickname_too_short => '昵称至少需要 2 个字符';

  @override
  String get nickname_too_long => '昵称不能超过 15 个字符';

  @override
  String get nickname_invalid_characters => '昵称只能包含字母、数字、下划线或连字符';

  @override
  String get nickname_only_numbers => '昵称不能只包含数字';

  @override
  String get game2048Subtitle => '滑動合併數字，挑戰 2048！';

  @override
  String get gameHubBannerTitle => '菸癮犯了？來玩遊戲轉移注意力！';

  @override
  String get gameHubBannerSubtitle => '所有遊戲完全內建，不需網路，隨時可玩 🎯';

  @override
  String get gameHubSelectGame => '選擇遊戲';

  @override
  String get gameHubOfflineBuiltIn => '✅ 完全內建 · 離線可玩';

  @override
  String get medicalLibraryTitle => '醫學知識庫';

  @override
  String get medicalLibraryEmpty => '目前沒有醫學文章。';

  @override
  String get medicalLibraryLoadFailed => '載入醫學文章失敗，請稍後再試。';

  @override
  String get medicalVip => 'VIP';

  @override
  String get medicalSummaryUnavailable => '暫無摘要內容。';

  @override
  String get storyLibraryTitle => '戒菸故事';

  @override
  String get storyLibraryEmpty => '目前沒有故事內容。';

  @override
  String get storyLibraryLoadFailed => '載入故事內容失敗，請稍後再試。';

  @override
  String get storySummaryUnavailable => '暫無故事摘要。';

  @override
  String get musicLibraryTitle => '放鬆音樂';

  @override
  String get musicLibraryEmpty => '目前沒有可用音樂內容。';

  @override
  String get musicLibraryLoadFailed => '載入音樂內容失敗，請稍後再試。';

  @override
  String get musicSummaryUnavailable => '暫無內容說明。';

  @override
  String get musicSourceLink => '來源連結';
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
  String get quitPlanPageTitle => '戒菸計畫';

  @override
  String get quitPlanDailyCigarettes => '每日抽菸數';

  @override
  String get quitPlanPricePerPack => '每包價格';

  @override
  String get quitPlanCigarettesPerPack => '每包支數';

  @override
  String get quitPlanDays => '戒菸天數';

  @override
  String get quitPlanGenerateButton => '產生戒菸計畫';

  @override
  String quitPlanEstimatedSavings(Object saving) {
    return '預估節省：$saving 元';
  }

  @override
  String quitPlanDayLabel(Object day) {
    return '第 $day 天';
  }

  @override
  String plannedCigarettes(Object count) {
    return '🚬 $count 支';
  }

  @override
  String get previousStep => '上一步';

  @override
  String get nextStep => '下一步';

  @override
  String usernameAlreadyUsed(Object name) {
    return '「$name」已被使用，請換一個';
  }

  @override
  String usernameAlreadyUsedPleaseEdit(Object name) {
    return '「$name」已被使用，請返回修改';
  }

  @override
  String get usernameStartQuitJourney => '開始戒菸之旅 🚀';

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
  String dailySignInNotification(Object rank) {
    return '📆 跨天簽到：您目前為 [$rank]';
  }

  @override
  String dailyRewardNotification(Object reward) {
    return '💰 系統已自動發放今日福利 $reward 金幣！';
  }

  @override
  String get smokingUnlockNotification => '🔔 控菸時間已到！新一輪配額已解鎖，您今天已成功少抽 2 支菸！';

  @override
  String get smokeSuccessMessage => '🎉 你太棒了，少抽一支菸！';

  @override
  String get cravingWarningMessage => '🚨 警告：使用者菸癮犯了！已通知好友！';

  @override
  String get friendEncouragementMessage => '💬 好友小明：堅持住！快進入下方的緩解艙！';

  @override
  String get cravingReliefChamberTitle => '🚨 菸癮危機緩解艙';

  @override
  String get mitigationTileMedical => '1. 醫學常識 (內建戒菸文章)';

  @override
  String get mitigationTileShortJokes => '2. 極短篇笑話 (短文小故事)';

  @override
  String get readingArticleOfflineLabel => '閱讀文章（下載後可離線閱讀）';

  @override
  String get youtubeVideoLabel => '3. YouTube影片 (看一下影片)';

  @override
  String get musicLinkLabel => '4. 音樂連結 (聽一下音樂)';

  @override
  String cigarettesCount(Object count) {
    return '$count 支';
  }

  @override
  String currencyAmount(Object amount) {
    return '$amount 元';
  }

  @override
  String get todaySaved => '今日省下';

  @override
  String get smoked => '已抽 ✓';

  @override
  String get notRecorded => '未記錄';

  @override
  String get remainingAmount => '剩餘額度';

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

  @override
  String get readingTitle => '閱讀文章';

  @override
  String get readingEmpty => '目前沒有可閱讀的文章。';

  @override
  String get refresh => '重新整理';

  @override
  String get readingCoinInsufficient => 'COIN 不足，無法下載這篇文章。';

  @override
  String get downloadFailed => '下載失敗，請稍後再試。';

  @override
  String get downloadAndRead => '下載並閱讀';

  @override
  String get contentManagementTitle => '內容管理';

  @override
  String get contentManagementAdd => '新增內容';

  @override
  String get contentManagementNoData => '無內容資料';

  @override
  String get contentManagementEmpty => '目前無資料';

  @override
  String get contentManagementEditTitle => '編輯內容';

  @override
  String contentManagementCategory(Object category) {
    return '分類：$category';
  }

  @override
  String get contentManagementLanguageCode => '語言代碼 (zh-tw / en / es / all)';

  @override
  String get contentManagementTitleLabel => '標題';

  @override
  String get contentManagementContentLabel => '內容';

  @override
  String get contentManagementLinkLabel => '連結網址';

  @override
  String get loginEmail => '電子郵件';

  @override
  String get loginPassword => '密碼';

  @override
  String get loginWithEmail => '信箱登入';

  @override
  String get loginWithGoogle => '使用 Google 帳號登入';

  @override
  String get loginPasswordMinLength => '密碼 (至少6碼)';

  @override
  String get registerNewAccount => '註冊新帳號';

  @override
  String get enterValidEmail => '請輸入正確的電子郵件';

  @override
  String get passwordMinLengthError => '密碼至少需要 6 個字元';

  @override
  String get emailAlreadyRegistered => '此電子郵件已被註冊，請直接登入';

  @override
  String get weakPassword => '密碼強度不足';

  @override
  String get invalidEmailFormat => '電子郵件格式不正確';

  @override
  String get registrationFailed => '註冊失敗，請稍後再試';

  @override
  String get fillEmailAndPassword => '請填寫電子郵件與密碼';

  @override
  String get invalidEmailOrPassword => '電子郵件或密碼不正確';

  @override
  String get tooManyAttempts => '嘗試次數過多，請稍後再試';

  @override
  String get loginFailed => '登入失敗，請稍後再試';

  @override
  String loginFailedWithError(Object error) {
    return '登入失敗：$error';
  }

  @override
  String get externalLinkInvalidFormat => '連結格式無效，顯示內建內容。';

  @override
  String get externalLinkOpenTimeout => '外部連結無法在 10 秒內開啟；改為顯示內建內容。';

  @override
  String get externalLinkOpenFailed => '無法開啟外部連結，改為顯示內建內容。';

  @override
  String get onlineGameRecommendation => '🌐 推薦線上遊戲';

  @override
  String get nextTip => '下一則提示';

  @override
  String get randomTip => '隨機';

  @override
  String get successfullySurvivedButton => '🟢 我撐過了！';

  @override
  String get cravingTip => '💡 小提醒：當菸癮來襲時，深呼吸 3 次可幫助緩解不適！';

  @override
  String get offlineBuiltInLabel => '✅ 完全內建 · 離線可玩';

  @override
  String get motivationalQuote1 => '每一支沒抽的菸，都是你重新掌控生活的勝利！';

  @override
  String get motivationalQuote2 => '深呼吸！這口新鮮空氣比尼古丁更強大！';

  @override
  String get motivationalQuote3 => '菸癮通常只會持續約 3 分鐘，撐過就算贏！';

  @override
  String get motivationalQuote4 => '你省下的不是錢，而是和家人相處的時間！';

  @override
  String get motivationalQuote5 => '你比自己想像的還要強！';

  @override
  String get loginAppSloganTitle => '戒菸好習慣';

  @override
  String get loginAppSloganSubtitle => '陪你每天一步一步戒菸';

  @override
  String get loginTabSignIn => '登入';

  @override
  String get loginTabRegister => '註冊';

  @override
  String get introSlide1Title => '開始你的戒菸之旅';

  @override
  String get introSlide1Desc => '科學化的戒菸計畫，幫助你一步一步減少菸量，直到完全戒斷。每一天都是勝利。';

  @override
  String get introSlide2Title => '個人化排程計畫';

  @override
  String get introSlide2Desc => '根據你的抽菸習慣，系統自動生成最適合你的戒菸時間表，並即時追蹤進度。';

  @override
  String get introSlide3Title => '社群互助，不再孤單';

  @override
  String get introSlide3Desc => '加入戒菸社群，與同道人互相支持鼓勵。菸癮犯了？立即求救，大家都在。';

  @override
  String get introSkip => '略過';

  @override
  String get introGetStarted => '開始使用';

  @override
  String get introNext => '下一頁 ›';

  @override
  String get rankingGlobalTitle => '全球排行榜';

  @override
  String rankingQuitDays(Object days) {
    return '戒菸 $days 天';
  }

  @override
  String readingWaitSeconds(Object seconds) {
    return '請再閱讀 $seconds 秒後繼續。';
  }

  @override
  String get readingCompletedArticle => '已完成這篇文章。';

  @override
  String readingChapterProgress(Object current, Object total) {
    return '第 $current 章／共 $total 章';
  }

  @override
  String get readingCanContinue => '可以繼續下一章';

  @override
  String readingMinSeconds(Object seconds) {
    return '請閱讀至少 $seconds 秒';
  }

  @override
  String get readingFinish => '完成閱讀';

  @override
  String get readingContinueNextChapter => '繼續下一章';

  @override
  String shopBuyCoins(Object amount) {
    return '購買 $amount COIN';
  }

  @override
  String get shopCreateForumPost => '建立論壇貼文 (-30 COIN)';

  @override
  String get shopVipActive => 'VIP 已啟用';

  @override
  String get shopPremium => '高級會員';

  @override
  String get shopVip => 'VIP';

  @override
  String get forumInsufficientCoinsToGift => '金幣不足，請前往金幣商城。';

  @override
  String get forumCreatePostTitle => '創建新貼文';

  @override
  String get forumNeedCoinsToCreatePost => 'COIN 不足，請前往商城購買 COIN';

  @override
  String get forumCommentSuccessCostOneCoin => '留言成功，扣除 1 COIN';

  @override
  String get forumCommentFailed => '留言失敗';

  @override
  String get forumCommentNeedsOneCoin => '留言需要 1 COIN';

  @override
  String get forumWatchAdComment => '觀看廣告留言';

  @override
  String get forumGoToCoinShop => '前往 COIN 商城';

  @override
  String get forumBuyCoin => '購買 COIN';

  @override
  String get forumWatchingAd => '觀看廣告中...';

  @override
  String get forumPostDetailTitle => '文章詳情';

  @override
  String get forumComments => '留言';

  @override
  String get forumNoComments => '目前沒有留言';

  @override
  String get forumCommentHint => '輸入留言...';

  @override
  String get scheduleTitle => '戒菸排程';

  @override
  String scheduleDayRemaining(Object elapsed, Object remaining) {
    return '第 $elapsed 天 · 剩 $remaining 天';
  }

  @override
  String get scheduleWeeklyView => '本週視圖';

  @override
  String get scheduleMonthlyView => '月視圖';

  @override
  String get scheduleHeaderDay => '天數';

  @override
  String get scheduleHeaderDate => '日期';

  @override
  String get scheduleHeaderPlanned => '計畫';

  @override
  String get scheduleHeaderActual => '實際';

  @override
  String get scheduleLegendOnTarget => '達標';

  @override
  String get scheduleLegendOverTarget => '超標';

  @override
  String get scheduleLegendFutureOrEmpty => '未來/無記錄';

  @override
  String get setupBasicInfo => '基本資料';

  @override
  String get setupEdit => '編輯';

  @override
  String get setupNone => '無';

  @override
  String get setupAgeLabel => '年齡';

  @override
  String get setupSmokingYearsLabel => '菸齡';

  @override
  String setupYearsOld(Object value) {
    return '$value 歲';
  }

  @override
  String setupYearsValue(Object value) {
    return '$value 年';
  }

  @override
  String setupCigarettesPerDay(Object value) {
    return '$value 支';
  }

  @override
  String setupPricePerPack(Object value) {
    return '$value 元／包';
  }

  @override
  String get setupPlanDays => '計畫天數';

  @override
  String setupPlanDaysValue(Object days) {
    return '$days 天';
  }

  @override
  String get setupFirstSmokeTime => '第一支菸時間';

  @override
  String get setupLastSmokeTime => '最後一支菸時間';

  @override
  String get setupViewSchedule => '查詢戒菸行程';

  @override
  String get setupContentManagement => '內容管理後台';

  @override
  String get setupConfirmSignOut => '確認登出';

  @override
  String get setupSignOutConfirmMessage => '登出後資料將保留在雲端，下次登入即可同步回來。';

  @override
  String get setupSignOut => '登出';

  @override
  String get setupSignOutAccount => '登出帳號';

  @override
  String get setupEditBasicInfo => '編輯基本資料';

  @override
  String get setupSmokingYearsWithYear => '菸齡 (年)';

  @override
  String get setupDailyCigarettes => '每日吸菸支數';

  @override
  String get setupPricePerPackLabel => '香菸單價（每包）';

  @override
  String setupFirstSmokeWithTime(Object time) {
    return '第一支菸\n$time';
  }

  @override
  String setupLastSmokeWithTime(Object time) {
    return '最後一支菸\n$time';
  }

  @override
  String get setupPlanDaysLabel => '計畫天數：';

  @override
  String setupDaysCompact(Object days) {
    return '$days天';
  }

  @override
  String setupFormatError(Object error) {
    return '格式錯誤: $error';
  }

  @override
  String get onboardingNameRequired => '⚠️ 請輸入您的暱稱喔！';

  @override
  String get onboardingFeature1Title => '🌿 醫學級動態控菸排程';

  @override
  String get onboardingFeature1Desc =>
      '打破傳統死板定時器！隨時根據您的真實按下時間，動態向後延遲 90 分鐘計算。沒抽菸絕不鎖定，時間過期自動褪色變暗，輔以打勾連動實抽狀態！';

  @override
  String get onboardingFeature2Title => '👑 高級黑金代幣商城';

  @override
  String get onboardingFeature2Desc =>
      '內建階梯式寶箱充值包與奢華黑金漸層 VIP 會員卡。跨天 00:00 系統全自動識別一般/高級會員並智能補發福利金幣，完美串聯商務閉環！';

  @override
  String get onboardingFeature3Title => '🧡 高顏值卡片流交流論壇';

  @override
  String get onboardingFeature3Desc =>
      '首創社群卡片流 Social Feed。使用者遇到菸癮危機按下 SOS 時，系統秒自動同步發布即時求救貼文，大家可以花費 5 金幣送出禮物留言打氣！';

  @override
  String get onboardingWelcome => '歡迎加入戒菸俱樂部，重獲健康生活';

  @override
  String get onboardingCreateProfile => '✍️ 首次建立戒菸個人檔案';

  @override
  String get onboardingNicknameInput => '請輸入您的暱稱';

  @override
  String get onboardingDailyTarget => '今日目標控菸支數 (預設5支)';

  @override
  String get onboardingStartJourney => '開啟戒菸健康之旅';

  @override
  String get homePremiumMember => '高級會員';

  @override
  String get homeRegularMember => '一般會員';

  @override
  String get gameHubBuiltInMiniGames => '內建小遊戲';

  @override
  String get forumGoToForumLobby => '前往論壇大廳';

  @override
  String get nickname_empty => '暱稱不得為空';

  @override
  String get nickname_too_short => '暱稱至少需要 2 個字元';

  @override
  String get nickname_too_long => '暱稱不可超過 15 個字元';

  @override
  String get nickname_invalid_characters => '暱稱只能包含字母、數字、底線或連字號';

  @override
  String get nickname_only_numbers => '暱稱不可只包含數字';

  @override
  String get game2048Subtitle => '滑動合併數字，挑戰 2048！';

  @override
  String get gameHubBannerTitle => '菸癮犯了？來玩遊戲轉移注意力！';

  @override
  String get gameHubBannerSubtitle => '所有遊戲完全內建，不需網路，隨時可玩 🎯';

  @override
  String get gameHubSelectGame => '選擇遊戲';

  @override
  String get gameHubOfflineBuiltIn => '✅ 完全內建 · 離線可玩';

  @override
  String get medicalLibraryTitle => '醫學知識庫';

  @override
  String get medicalLibraryEmpty => '目前沒有醫學文章。';

  @override
  String get medicalLibraryLoadFailed => '載入醫學文章失敗，請稍後再試。';

  @override
  String get medicalVip => 'VIP';

  @override
  String get medicalSummaryUnavailable => '暫無摘要內容。';

  @override
  String get storyLibraryTitle => '戒菸故事';

  @override
  String get storyLibraryEmpty => '目前沒有故事內容。';

  @override
  String get storyLibraryLoadFailed => '載入故事內容失敗，請稍後再試。';

  @override
  String get storySummaryUnavailable => '暫無故事摘要。';

  @override
  String get musicLibraryTitle => '放鬆音樂';

  @override
  String get musicLibraryEmpty => '目前沒有可用音樂內容。';

  @override
  String get musicLibraryLoadFailed => '載入音樂內容失敗，請稍後再試。';

  @override
  String get musicSummaryUnavailable => '暫無內容說明。';

  @override
  String get musicSourceLink => '來源連結';
}
