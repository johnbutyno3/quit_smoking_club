import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸俱樂部'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In zh_TW, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @quitPlan.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸計畫'**
  String get quitPlan;

  /// No description provided for @welcomeMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'歡迎來到戒菸俱樂部！挑戰正在進行中。'**
  String get welcomeMessage;

  /// No description provided for @hello.
  ///
  /// In zh_TW, this message translates to:
  /// **'你好'**
  String get hello;

  /// No description provided for @dailyCount.
  ///
  /// In zh_TW, this message translates to:
  /// **'每日抽菸量'**
  String get dailyCount;

  /// No description provided for @cigarettePrice.
  ///
  /// In zh_TW, this message translates to:
  /// **'香菸單價'**
  String get cigarettePrice;

  /// No description provided for @save.
  ///
  /// In zh_TW, this message translates to:
  /// **'儲存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh_TW, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @forum.
  ///
  /// In zh_TW, this message translates to:
  /// **'交流論壇'**
  String get forum;

  /// No description provided for @shop.
  ///
  /// In zh_TW, this message translates to:
  /// **'金幣商城'**
  String get shop;

  /// No description provided for @gameHub.
  ///
  /// In zh_TW, this message translates to:
  /// **'遊戲大廳'**
  String get gameHub;

  /// No description provided for @recordSmoke.
  ///
  /// In zh_TW, this message translates to:
  /// **'記錄抽菸'**
  String get recordSmoke;

  /// No description provided for @locked.
  ///
  /// In zh_TW, this message translates to:
  /// **'待解鎖'**
  String get locked;

  /// No description provided for @sos.
  ///
  /// In zh_TW, this message translates to:
  /// **'SOS 求協助'**
  String get sos;

  /// No description provided for @smokedCount.
  ///
  /// In zh_TW, this message translates to:
  /// **'已抽支數'**
  String get smokedCount;

  /// No description provided for @remaining.
  ///
  /// In zh_TW, this message translates to:
  /// **'剩餘額度'**
  String get remaining;

  /// No description provided for @countdown.
  ///
  /// In zh_TW, this message translates to:
  /// **'距離下一次解鎖抽菸倒數'**
  String get countdown;

  /// No description provided for @todaySchedule.
  ///
  /// In zh_TW, this message translates to:
  /// **'控菸今日排程表'**
  String get todaySchedule;

  /// No description provided for @createPost.
  ///
  /// In zh_TW, this message translates to:
  /// **'建立貼文'**
  String get createPost;

  /// No description provided for @postName.
  ///
  /// In zh_TW, this message translates to:
  /// **'暱稱'**
  String get postName;

  /// No description provided for @postContent.
  ///
  /// In zh_TW, this message translates to:
  /// **'貼文內容'**
  String get postContent;

  /// No description provided for @publish.
  ///
  /// In zh_TW, this message translates to:
  /// **'發布'**
  String get publish;

  /// No description provided for @myCoins.
  ///
  /// In zh_TW, this message translates to:
  /// **'我的 COIN'**
  String get myCoins;

  /// No description provided for @giftSent.
  ///
  /// In zh_TW, this message translates to:
  /// **'禮物送出成功'**
  String get giftSent;

  /// No description provided for @insufficientCoins.
  ///
  /// In zh_TW, this message translates to:
  /// **'COIN 不足'**
  String get insufficientCoins;

  /// No description provided for @postCreated.
  ///
  /// In zh_TW, this message translates to:
  /// **'貼文建立成功'**
  String get postCreated;

  /// No description provided for @anonymousUser.
  ///
  /// In zh_TW, this message translates to:
  /// **'匿名朋友'**
  String get anonymousUser;

  /// No description provided for @like.
  ///
  /// In zh_TW, this message translates to:
  /// **'讚'**
  String get like;

  /// No description provided for @gift.
  ///
  /// In zh_TW, this message translates to:
  /// **'禮物'**
  String get gift;

  /// No description provided for @now.
  ///
  /// In zh_TW, this message translates to:
  /// **'剛剛'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 分鐘前'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 小時前'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 天前'**
  String daysAgo(Object count);

  /// No description provided for @emptyForum.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前尚無論壇貼文，快建立第一篇吧！'**
  String get emptyForum;

  /// No description provided for @sosPost.
  ///
  /// In zh_TW, this message translates to:
  /// **'求助文章'**
  String get sosPost;

  /// No description provided for @coinHistory.
  ///
  /// In zh_TW, this message translates to:
  /// **'COIN 紀錄'**
  String get coinHistory;

  /// No description provided for @currentBalance.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前餘額'**
  String get currentBalance;

  /// No description provided for @noTransactionHistory.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有交易紀錄'**
  String get noTransactionHistory;

  /// No description provided for @purchaseSuccess.
  ///
  /// In zh_TW, this message translates to:
  /// **'購買成功'**
  String get purchaseSuccess;

  /// No description provided for @premiumActivated.
  ///
  /// In zh_TW, this message translates to:
  /// **'高級會員已啟用'**
  String get premiumActivated;

  /// No description provided for @achievementDay1Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'第一天'**
  String get achievementDay1Title;

  /// No description provided for @achievementDay1Description.
  ///
  /// In zh_TW, this message translates to:
  /// **'開始戒菸旅程'**
  String get achievementDay1Description;

  /// No description provided for @achievementDay7Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'一週達成'**
  String get achievementDay7Title;

  /// No description provided for @achievementDay7Description.
  ///
  /// In zh_TW, this message translates to:
  /// **'連續戒菸 7 天'**
  String get achievementDay7Description;

  /// No description provided for @achievementDay30Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'一個月達成'**
  String get achievementDay30Title;

  /// No description provided for @achievementDay30Description.
  ///
  /// In zh_TW, this message translates to:
  /// **'連續戒菸 30 天'**
  String get achievementDay30Description;

  /// No description provided for @achievementMoney1000Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'省下 1000 元'**
  String get achievementMoney1000Title;

  /// No description provided for @achievementMoney1000Description.
  ///
  /// In zh_TW, this message translates to:
  /// **'累積省下 1000 元'**
  String get achievementMoney1000Description;

  /// No description provided for @achievementRecoveryTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'健康恢復'**
  String get achievementRecoveryTitle;

  /// No description provided for @achievementRecoveryDescription.
  ///
  /// In zh_TW, this message translates to:
  /// **'完成第一個身體恢復里程碑'**
  String get achievementRecoveryDescription;

  /// No description provided for @achievementDay7Progress.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未完成 7 天戒菸目標'**
  String get achievementDay7Progress;

  /// No description provided for @achievementDay30Progress.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未完成 30 天戒菸目標'**
  String get achievementDay30Progress;

  /// No description provided for @achievementMoney1000Progress.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未累積省下 1000 元'**
  String get achievementMoney1000Progress;

  /// No description provided for @achievementRecoveryProgress.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未完成健康恢復階段'**
  String get achievementRecoveryProgress;

  /// No description provided for @todayAchievement.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日成就'**
  String get todayAchievement;

  /// No description provided for @achievementCompleted.
  ///
  /// In zh_TW, this message translates to:
  /// **'完成 {completed} / {total}'**
  String achievementCompleted(Object completed, Object total);

  /// No description provided for @quitProgress.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸進度'**
  String get quitProgress;

  /// No description provided for @dayProgress.
  ///
  /// In zh_TW, this message translates to:
  /// **'Day {current} / {total}'**
  String dayProgress(Object current, Object total);

  /// No description provided for @todayGoal.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日目標：{count} 支'**
  String todayGoal(Object count);

  /// No description provided for @smokedToday.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日已抽：{count} 支'**
  String smokedToday(Object count);

  /// No description provided for @remainingToday.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日剩餘：{count} 支'**
  String remainingToday(Object count);

  /// No description provided for @startQuitTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'開始你的戒菸計畫'**
  String get startQuitTitle;

  /// No description provided for @startQuitDescription.
  ///
  /// In zh_TW, this message translates to:
  /// **'建立專屬戒菸方案，追蹤你的健康變化，加入社群支持。'**
  String get startQuitDescription;

  /// No description provided for @startPlan.
  ///
  /// In zh_TW, this message translates to:
  /// **'開始計畫'**
  String get startPlan;

  /// No description provided for @lifestyleTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'健康生活'**
  String get lifestyleTitle;

  /// No description provided for @exercise.
  ///
  /// In zh_TW, this message translates to:
  /// **'運動挑戰'**
  String get exercise;

  /// No description provided for @healthKnowledge.
  ///
  /// In zh_TW, this message translates to:
  /// **'健康知識'**
  String get healthKnowledge;

  /// No description provided for @relaxMusic.
  ///
  /// In zh_TW, this message translates to:
  /// **'放鬆音樂'**
  String get relaxMusic;

  /// No description provided for @ranking.
  ///
  /// In zh_TW, this message translates to:
  /// **'排行榜'**
  String get ranking;

  /// No description provided for @coinBalanceTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前擁有金幣庫存'**
  String get coinBalanceTitle;

  /// No description provided for @nextSmokeCountdown.
  ///
  /// In zh_TW, this message translates to:
  /// **'距離下一次解鎖抽菸倒數'**
  String get nextSmokeCountdown;

  /// No description provided for @sosHelp.
  ///
  /// In zh_TW, this message translates to:
  /// **'SOS 求協助'**
  String get sosHelp;

  /// No description provided for @recordSmoking.
  ///
  /// In zh_TW, this message translates to:
  /// **'記錄抽菸'**
  String get recordSmoking;

  /// No description provided for @notUnlocked.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未解鎖'**
  String get notUnlocked;

  /// No description provided for @coinShop.
  ///
  /// In zh_TW, this message translates to:
  /// **'金幣商城'**
  String get coinShop;

  /// No description provided for @todaySmokingSchedule.
  ///
  /// In zh_TW, this message translates to:
  /// **'控菸今日排程表'**
  String get todaySmokingSchedule;

  /// No description provided for @smoked.
  ///
  /// In zh_TW, this message translates to:
  /// **'已抽 ✓'**
  String get smoked;

  /// No description provided for @notRecorded.
  ///
  /// In zh_TW, this message translates to:
  /// **'未記錄'**
  String get notRecorded;

  /// No description provided for @remainingAmount.
  ///
  /// In zh_TW, this message translates to:
  /// **'剩餘額度'**
  String get remainingAmount;

  /// No description provided for @todaySaved.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日省下'**
  String get todaySaved;

  /// No description provided for @coinUnit.
  ///
  /// In zh_TW, this message translates to:
  /// **'金幣'**
  String get coinUnit;

  /// No description provided for @forumCategoryAll.
  ///
  /// In zh_TW, this message translates to:
  /// **'全部'**
  String get forumCategoryAll;

  /// No description provided for @forumCategoryCraving.
  ///
  /// In zh_TW, this message translates to:
  /// **'菸癮犯了'**
  String get forumCategoryCraving;

  /// No description provided for @forumCategoryStory.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸心得'**
  String get forumCategoryStory;

  /// No description provided for @forumCategoryHealth.
  ///
  /// In zh_TW, this message translates to:
  /// **'健康交流'**
  String get forumCategoryHealth;

  /// No description provided for @forumCategorySupport.
  ///
  /// In zh_TW, this message translates to:
  /// **'互相鼓勵'**
  String get forumCategorySupport;

  /// No description provided for @achievementSpending1000Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'消費 1000 金幣'**
  String get achievementSpending1000Title;

  /// No description provided for @achievementSpending1000Description.
  ///
  /// In zh_TW, this message translates to:
  /// **'累積消費 1000 金幣'**
  String get achievementSpending1000Description;

  /// No description provided for @achievementSpending1000Progress.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚未消費 1000 金幣'**
  String get achievementSpending1000Progress;

  /// No description provided for @readingTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'閱讀文章'**
  String get readingTitle;

  /// No description provided for @readingEmpty.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有可閱讀的文章。'**
  String get readingEmpty;

  /// No description provided for @refresh.
  ///
  /// In zh_TW, this message translates to:
  /// **'重新整理'**
  String get refresh;

  /// No description provided for @readingCoinInsufficient.
  ///
  /// In zh_TW, this message translates to:
  /// **'COIN 不足，無法下載這篇文章。'**
  String get readingCoinInsufficient;

  /// No description provided for @downloadFailed.
  ///
  /// In zh_TW, this message translates to:
  /// **'下載失敗，請稍後再試。'**
  String get downloadFailed;

  /// No description provided for @downloadAndRead.
  ///
  /// In zh_TW, this message translates to:
  /// **'下載並閱讀'**
  String get downloadAndRead;

  /// No description provided for @contentManagementTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'內容管理'**
  String get contentManagementTitle;

  /// No description provided for @contentManagementAdd.
  ///
  /// In zh_TW, this message translates to:
  /// **'新增內容'**
  String get contentManagementAdd;

  /// No description provided for @contentManagementNoData.
  ///
  /// In zh_TW, this message translates to:
  /// **'無內容資料'**
  String get contentManagementNoData;

  /// No description provided for @contentManagementEmpty.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前無資料'**
  String get contentManagementEmpty;

  /// No description provided for @contentManagementEditTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'編輯內容'**
  String get contentManagementEditTitle;

  /// No description provided for @contentManagementCategory.
  ///
  /// In zh_TW, this message translates to:
  /// **'分類：{category}'**
  String contentManagementCategory(Object category);

  /// No description provided for @contentManagementLanguageCode.
  ///
  /// In zh_TW, this message translates to:
  /// **'語言代碼 (zh-tw / en / es / all)'**
  String get contentManagementLanguageCode;

  /// No description provided for @contentManagementTitleLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'標題'**
  String get contentManagementTitleLabel;

  /// No description provided for @contentManagementContentLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'內容'**
  String get contentManagementContentLabel;

  /// No description provided for @contentManagementLinkLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'連結網址'**
  String get contentManagementLinkLabel;

  /// No description provided for @loginEmail.
  ///
  /// In zh_TW, this message translates to:
  /// **'電子郵件'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In zh_TW, this message translates to:
  /// **'密碼'**
  String get loginPassword;

  /// No description provided for @loginWithEmail.
  ///
  /// In zh_TW, this message translates to:
  /// **'信箱登入'**
  String get loginWithEmail;

  /// No description provided for @loginWithGoogle.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用 Google 帳號登入'**
  String get loginWithGoogle;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In zh_TW, this message translates to:
  /// **'密碼 (至少6碼)'**
  String get loginPasswordMinLength;

  /// No description provided for @registerNewAccount.
  ///
  /// In zh_TW, this message translates to:
  /// **'註冊新帳號'**
  String get registerNewAccount;

  /// No description provided for @loginAppSloganTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸好習慣'**
  String get loginAppSloganTitle;

  /// No description provided for @loginAppSloganSubtitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'陪你每天一步一步戒菸'**
  String get loginAppSloganSubtitle;

  /// No description provided for @loginTabSignIn.
  ///
  /// In zh_TW, this message translates to:
  /// **'登入'**
  String get loginTabSignIn;

  /// No description provided for @loginTabRegister.
  ///
  /// In zh_TW, this message translates to:
  /// **'註冊'**
  String get loginTabRegister;

  /// No description provided for @introSlide1Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'開始你的戒菸之旅'**
  String get introSlide1Title;

  /// No description provided for @introSlide1Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'科學化的戒菸計畫，幫助你一步一步減少菸量，直到完全戒斷。每一天都是勝利。'**
  String get introSlide1Desc;

  /// No description provided for @introSlide2Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'個人化排程計畫'**
  String get introSlide2Title;

  /// No description provided for @introSlide2Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'根據你的抽菸習慣，系統自動生成最適合你的戒菸時間表，並即時追蹤進度。'**
  String get introSlide2Desc;

  /// No description provided for @introSlide3Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'社群互助，不再孤單'**
  String get introSlide3Title;

  /// No description provided for @introSlide3Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'加入戒菸社群，與同道人互相支持鼓勵。菸癮犯了？立即求救，大家都在。'**
  String get introSlide3Desc;

  /// No description provided for @introSkip.
  ///
  /// In zh_TW, this message translates to:
  /// **'略過'**
  String get introSkip;

  /// No description provided for @introGetStarted.
  ///
  /// In zh_TW, this message translates to:
  /// **'開始使用'**
  String get introGetStarted;

  /// No description provided for @introNext.
  ///
  /// In zh_TW, this message translates to:
  /// **'下一頁 ›'**
  String get introNext;

  /// No description provided for @rankingGlobalTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'全球排行榜'**
  String get rankingGlobalTitle;

  /// No description provided for @rankingQuitDays.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸 {days} 天'**
  String rankingQuitDays(Object days);

  /// No description provided for @readingWaitSeconds.
  ///
  /// In zh_TW, this message translates to:
  /// **'請再閱讀 {seconds} 秒後繼續。'**
  String readingWaitSeconds(Object seconds);

  /// No description provided for @readingCompletedArticle.
  ///
  /// In zh_TW, this message translates to:
  /// **'已完成這篇文章。'**
  String get readingCompletedArticle;

  /// No description provided for @readingChapterProgress.
  ///
  /// In zh_TW, this message translates to:
  /// **'第 {current} 章／共 {total} 章'**
  String readingChapterProgress(Object current, Object total);

  /// No description provided for @readingCanContinue.
  ///
  /// In zh_TW, this message translates to:
  /// **'可以繼續下一章'**
  String get readingCanContinue;

  /// No description provided for @readingMinSeconds.
  ///
  /// In zh_TW, this message translates to:
  /// **'請閱讀至少 {seconds} 秒'**
  String readingMinSeconds(Object seconds);

  /// No description provided for @readingFinish.
  ///
  /// In zh_TW, this message translates to:
  /// **'完成閱讀'**
  String get readingFinish;

  /// No description provided for @readingContinueNextChapter.
  ///
  /// In zh_TW, this message translates to:
  /// **'繼續下一章'**
  String get readingContinueNextChapter;

  /// No description provided for @shopBuyCoins.
  ///
  /// In zh_TW, this message translates to:
  /// **'購買 {amount} COIN'**
  String shopBuyCoins(Object amount);

  /// No description provided for @shopCreateForumPost.
  ///
  /// In zh_TW, this message translates to:
  /// **'建立論壇貼文 (-30 COIN)'**
  String get shopCreateForumPost;

  /// No description provided for @shopVipActive.
  ///
  /// In zh_TW, this message translates to:
  /// **'VIP 已啟用'**
  String get shopVipActive;

  /// No description provided for @shopPremium.
  ///
  /// In zh_TW, this message translates to:
  /// **'高級會員'**
  String get shopPremium;

  /// No description provided for @shopVip.
  ///
  /// In zh_TW, this message translates to:
  /// **'VIP'**
  String get shopVip;

  /// No description provided for @forumInsufficientCoinsToGift.
  ///
  /// In zh_TW, this message translates to:
  /// **'金幣不足，請前往金幣商城。'**
  String get forumInsufficientCoinsToGift;

  /// No description provided for @forumCreatePostTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'創建新貼文'**
  String get forumCreatePostTitle;

  /// No description provided for @forumNeedCoinsToCreatePost.
  ///
  /// In zh_TW, this message translates to:
  /// **'COIN 不足，請前往商城購買 COIN'**
  String get forumNeedCoinsToCreatePost;

  /// No description provided for @forumCommentSuccessCostOneCoin.
  ///
  /// In zh_TW, this message translates to:
  /// **'留言成功，扣除 1 COIN'**
  String get forumCommentSuccessCostOneCoin;

  /// No description provided for @forumCommentFailed.
  ///
  /// In zh_TW, this message translates to:
  /// **'留言失敗'**
  String get forumCommentFailed;

  /// No description provided for @forumCommentNeedsOneCoin.
  ///
  /// In zh_TW, this message translates to:
  /// **'留言需要 1 COIN'**
  String get forumCommentNeedsOneCoin;

  /// No description provided for @forumWatchAdComment.
  ///
  /// In zh_TW, this message translates to:
  /// **'觀看廣告留言'**
  String get forumWatchAdComment;

  /// No description provided for @forumGoToCoinShop.
  ///
  /// In zh_TW, this message translates to:
  /// **'前往 COIN 商城'**
  String get forumGoToCoinShop;

  /// No description provided for @forumBuyCoin.
  ///
  /// In zh_TW, this message translates to:
  /// **'購買 COIN'**
  String get forumBuyCoin;

  /// No description provided for @forumWatchingAd.
  ///
  /// In zh_TW, this message translates to:
  /// **'觀看廣告中...'**
  String get forumWatchingAd;

  /// No description provided for @forumPostDetailTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'文章詳情'**
  String get forumPostDetailTitle;

  /// No description provided for @forumComments.
  ///
  /// In zh_TW, this message translates to:
  /// **'留言'**
  String get forumComments;

  /// No description provided for @forumNoComments.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有留言'**
  String get forumNoComments;

  /// No description provided for @forumCommentHint.
  ///
  /// In zh_TW, this message translates to:
  /// **'輸入留言...'**
  String get forumCommentHint;

  /// No description provided for @scheduleTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'戒菸排程'**
  String get scheduleTitle;

  /// No description provided for @scheduleDayRemaining.
  ///
  /// In zh_TW, this message translates to:
  /// **'第 {elapsed} 天 · 剩 {remaining} 天'**
  String scheduleDayRemaining(Object elapsed, Object remaining);

  /// No description provided for @scheduleWeeklyView.
  ///
  /// In zh_TW, this message translates to:
  /// **'本週視圖'**
  String get scheduleWeeklyView;

  /// No description provided for @scheduleMonthlyView.
  ///
  /// In zh_TW, this message translates to:
  /// **'月視圖'**
  String get scheduleMonthlyView;

  /// No description provided for @scheduleHeaderDay.
  ///
  /// In zh_TW, this message translates to:
  /// **'天數'**
  String get scheduleHeaderDay;

  /// No description provided for @scheduleHeaderDate.
  ///
  /// In zh_TW, this message translates to:
  /// **'日期'**
  String get scheduleHeaderDate;

  /// No description provided for @scheduleHeaderPlanned.
  ///
  /// In zh_TW, this message translates to:
  /// **'計畫'**
  String get scheduleHeaderPlanned;

  /// No description provided for @scheduleHeaderActual.
  ///
  /// In zh_TW, this message translates to:
  /// **'實際'**
  String get scheduleHeaderActual;

  /// No description provided for @scheduleLegendOnTarget.
  ///
  /// In zh_TW, this message translates to:
  /// **'達標'**
  String get scheduleLegendOnTarget;

  /// No description provided for @scheduleLegendOverTarget.
  ///
  /// In zh_TW, this message translates to:
  /// **'超標'**
  String get scheduleLegendOverTarget;

  /// No description provided for @scheduleLegendFutureOrEmpty.
  ///
  /// In zh_TW, this message translates to:
  /// **'未來/無記錄'**
  String get scheduleLegendFutureOrEmpty;

  /// No description provided for @setupBasicInfo.
  ///
  /// In zh_TW, this message translates to:
  /// **'基本資料'**
  String get setupBasicInfo;

  /// No description provided for @setupEdit.
  ///
  /// In zh_TW, this message translates to:
  /// **'編輯'**
  String get setupEdit;

  /// No description provided for @setupNone.
  ///
  /// In zh_TW, this message translates to:
  /// **'無'**
  String get setupNone;

  /// No description provided for @setupAgeLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'年齡'**
  String get setupAgeLabel;

  /// No description provided for @setupSmokingYearsLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'菸齡'**
  String get setupSmokingYearsLabel;

  /// No description provided for @setupYearsOld.
  ///
  /// In zh_TW, this message translates to:
  /// **'{value} 歲'**
  String setupYearsOld(Object value);

  /// No description provided for @setupYearsValue.
  ///
  /// In zh_TW, this message translates to:
  /// **'{value} 年'**
  String setupYearsValue(Object value);

  /// No description provided for @setupCigarettesPerDay.
  ///
  /// In zh_TW, this message translates to:
  /// **'{value} 支'**
  String setupCigarettesPerDay(Object value);

  /// No description provided for @setupPricePerPack.
  ///
  /// In zh_TW, this message translates to:
  /// **'{value} 元／包'**
  String setupPricePerPack(Object value);

  /// No description provided for @setupPlanDays.
  ///
  /// In zh_TW, this message translates to:
  /// **'計畫天數'**
  String get setupPlanDays;

  /// No description provided for @setupPlanDaysValue.
  ///
  /// In zh_TW, this message translates to:
  /// **'{days} 天'**
  String setupPlanDaysValue(Object days);

  /// No description provided for @setupFirstSmokeTime.
  ///
  /// In zh_TW, this message translates to:
  /// **'第一支菸時間'**
  String get setupFirstSmokeTime;

  /// No description provided for @setupLastSmokeTime.
  ///
  /// In zh_TW, this message translates to:
  /// **'最後一支菸時間'**
  String get setupLastSmokeTime;

  /// No description provided for @setupViewSchedule.
  ///
  /// In zh_TW, this message translates to:
  /// **'查詢戒菸行程'**
  String get setupViewSchedule;

  /// No description provided for @setupContentManagement.
  ///
  /// In zh_TW, this message translates to:
  /// **'內容管理後台'**
  String get setupContentManagement;

  /// No description provided for @setupConfirmSignOut.
  ///
  /// In zh_TW, this message translates to:
  /// **'確認登出'**
  String get setupConfirmSignOut;

  /// No description provided for @setupSignOutConfirmMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'登出後資料將保留在雲端，下次登入即可同步回來。'**
  String get setupSignOutConfirmMessage;

  /// No description provided for @setupSignOut.
  ///
  /// In zh_TW, this message translates to:
  /// **'登出'**
  String get setupSignOut;

  /// No description provided for @setupSignOutAccount.
  ///
  /// In zh_TW, this message translates to:
  /// **'登出帳號'**
  String get setupSignOutAccount;

  /// No description provided for @setupEditBasicInfo.
  ///
  /// In zh_TW, this message translates to:
  /// **'編輯基本資料'**
  String get setupEditBasicInfo;

  /// No description provided for @setupSmokingYearsWithYear.
  ///
  /// In zh_TW, this message translates to:
  /// **'菸齡 (年)'**
  String get setupSmokingYearsWithYear;

  /// No description provided for @setupDailyCigarettes.
  ///
  /// In zh_TW, this message translates to:
  /// **'每日吸菸支數'**
  String get setupDailyCigarettes;

  /// No description provided for @setupPricePerPackLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'香菸單價（每包）'**
  String get setupPricePerPackLabel;

  /// No description provided for @setupFirstSmokeWithTime.
  ///
  /// In zh_TW, this message translates to:
  /// **'第一支菸\n{time}'**
  String setupFirstSmokeWithTime(Object time);

  /// No description provided for @setupLastSmokeWithTime.
  ///
  /// In zh_TW, this message translates to:
  /// **'最後一支菸\n{time}'**
  String setupLastSmokeWithTime(Object time);

  /// No description provided for @setupPlanDaysLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'計畫天數：'**
  String get setupPlanDaysLabel;

  /// No description provided for @setupDaysCompact.
  ///
  /// In zh_TW, this message translates to:
  /// **'{days}天'**
  String setupDaysCompact(Object days);

  /// No description provided for @setupFormatError.
  ///
  /// In zh_TW, this message translates to:
  /// **'格式錯誤: {error}'**
  String setupFormatError(Object error);

  /// No description provided for @onboardingNameRequired.
  ///
  /// In zh_TW, this message translates to:
  /// **'⚠️ 請輸入您的暱稱喔！'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingFeature1Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'🌿 醫學級動態控菸排程'**
  String get onboardingFeature1Title;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'打破傳統死板定時器！隨時根據您的真實按下時間，動態向後延遲 90 分鐘計算。沒抽菸絕不鎖定，時間過期自動褪色變暗，輔以打勾連動實抽狀態！'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'👑 高級黑金代幣商城'**
  String get onboardingFeature2Title;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'內建階梯式寶箱充值包與奢華黑金漸層 VIP 會員卡。跨天 00:00 系統全自動識別一般/高級會員並智能補發福利金幣，完美串聯商務閉環！'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3Title.
  ///
  /// In zh_TW, this message translates to:
  /// **'🧡 高顏值卡片流交流論壇'**
  String get onboardingFeature3Title;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In zh_TW, this message translates to:
  /// **'首創社群卡片流 Social Feed。使用者遇到菸癮危機按下 SOS 時，系統秒自動同步發布即時求救貼文，大家可以花費 5 金幣送出禮物留言打氣！'**
  String get onboardingFeature3Desc;

  /// No description provided for @onboardingWelcome.
  ///
  /// In zh_TW, this message translates to:
  /// **'歡迎加入戒菸俱樂部，重獲健康生活'**
  String get onboardingWelcome;

  /// No description provided for @onboardingCreateProfile.
  ///
  /// In zh_TW, this message translates to:
  /// **'✍️ 首次建立戒菸個人檔案'**
  String get onboardingCreateProfile;

  /// No description provided for @onboardingNicknameInput.
  ///
  /// In zh_TW, this message translates to:
  /// **'請輸入您的暱稱'**
  String get onboardingNicknameInput;

  /// No description provided for @onboardingDailyTarget.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日目標控菸支數 (預設5支)'**
  String get onboardingDailyTarget;

  /// No description provided for @onboardingStartJourney.
  ///
  /// In zh_TW, this message translates to:
  /// **'開啟戒菸健康之旅'**
  String get onboardingStartJourney;

  /// No description provided for @game2048Subtitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'滑動合併數字，挑戰 2048！'**
  String get game2048Subtitle;

  /// No description provided for @gameHubBannerTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'菸癮犯了？來玩遊戲轉移注意力！'**
  String get gameHubBannerTitle;

  /// No description provided for @gameHubBannerSubtitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'所有遊戲完全內建，不需網路，隨時可玩 🎯'**
  String get gameHubBannerSubtitle;

  /// No description provided for @gameHubSelectGame.
  ///
  /// In zh_TW, this message translates to:
  /// **'選擇遊戲'**
  String get gameHubSelectGame;

  /// No description provided for @gameHubOfflineBuiltIn.
  ///
  /// In zh_TW, this message translates to:
  /// **'✅ 完全內建 · 離線可玩'**
  String get gameHubOfflineBuiltIn;

  /// No description provided for @medicalLibraryTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'醫學知識庫'**
  String get medicalLibraryTitle;

  /// No description provided for @medicalLibraryEmpty.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有醫學文章。'**
  String get medicalLibraryEmpty;

  /// No description provided for @medicalLibraryLoadFailed.
  ///
  /// In zh_TW, this message translates to:
  /// **'載入醫學文章失敗，請稍後再試。'**
  String get medicalLibraryLoadFailed;

  /// No description provided for @medicalVip.
  ///
  /// In zh_TW, this message translates to:
  /// **'VIP'**
  String get medicalVip;

  /// No description provided for @medicalSummaryUnavailable.
  ///
  /// In zh_TW, this message translates to:
  /// **'暫無摘要內容。'**
  String get medicalSummaryUnavailable;

  /// No description provided for @musicLibraryTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'放鬆音樂'**
  String get musicLibraryTitle;

  /// No description provided for @musicLibraryEmpty.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有可用音樂內容。'**
  String get musicLibraryEmpty;

  /// No description provided for @musicLibraryLoadFailed.
  ///
  /// In zh_TW, this message translates to:
  /// **'載入音樂內容失敗，請稍後再試。'**
  String get musicLibraryLoadFailed;

  /// No description provided for @musicSummaryUnavailable.
  ///
  /// In zh_TW, this message translates to:
  /// **'暫無內容說明。'**
  String get musicSummaryUnavailable;

  /// No description provided for @musicSourceLink.
  ///
  /// In zh_TW, this message translates to:
  /// **'來源連結'**
  String get musicSourceLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
