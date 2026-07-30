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
