// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quit Smoking Club';

  @override
  String get settings => 'Settings';

  @override
  String get quitPlan => 'Quit Plan';

  @override
  String get welcomeMessage =>
      'Welcome to Quit Smoking Club! Your challenge is in progress.';

  @override
  String get hello => 'Hello';

  @override
  String get dailyCount => 'Daily Cigarette Count';

  @override
  String get cigarettePrice => 'Cigarette Price';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get forum => 'Community Forum';

  @override
  String get shop => 'Coin Shop';

  @override
  String get gameHub => 'Game Hub';

  @override
  String get recordSmoke => 'Record Smoking';

  @override
  String get locked => 'Locked';

  @override
  String get sos => 'SOS Help';

  @override
  String get smokedCount => 'Smoked';

  @override
  String get remaining => 'Remaining';

  @override
  String get countdown => 'Countdown to Next Unlock';

  @override
  String get todaySchedule => 'Today\'s Smoking Schedule';

  @override
  String get createPost => 'Create Post';

  @override
  String get postName => 'Nickname';

  @override
  String get postContent => 'Post Content';

  @override
  String get publish => 'Publish';

  @override
  String get myCoins => 'My COIN';

  @override
  String get giftSent => 'Gift sent successfully';

  @override
  String get insufficientCoins => 'Insufficient COIN';

  @override
  String get postCreated => 'Post created successfully';

  @override
  String get anonymousUser => 'Anonymous Friend';

  @override
  String get like => 'Like';

  @override
  String get gift => 'Gift';

  @override
  String get now => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get emptyForum => 'No forum posts yet. Create the first one!';

  @override
  String get sosPost => 'Help Request Post';

  @override
  String get coinHistory => 'COIN History';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get noTransactionHistory => 'No transaction history';

  @override
  String get purchaseSuccess => 'Purchase Successful';

  @override
  String get premiumActivated => 'Premium membership activated';

  @override
  String get achievementDay1Title => 'First Day';

  @override
  String get achievementDay1Description => 'Started the quit smoking journey';

  @override
  String get achievementDay7Title => 'One Week Completed';

  @override
  String get achievementDay7Description =>
      'Quit smoking for 7 consecutive days';

  @override
  String get achievementDay30Title => 'One Month Completed';

  @override
  String get achievementDay30Description =>
      'Quit smoking for 30 consecutive days';

  @override
  String get achievementMoney1000Title => 'Saved 1000';

  @override
  String get achievementMoney1000Description => 'Saved 1000 in total';

  @override
  String get achievementRecoveryTitle => 'Health Recovery';

  @override
  String get achievementRecoveryDescription =>
      'Completed the first health recovery milestone';

  @override
  String get achievementDay7Progress => '7-day quit goal not completed yet';

  @override
  String get achievementDay30Progress => '30-day quit goal not completed yet';

  @override
  String get achievementMoney1000Progress => 'Have not saved 1000 yet';

  @override
  String get achievementRecoveryProgress =>
      'Health recovery stage not completed yet';

  @override
  String get todayAchievement => 'Today\'s Achievements';

  @override
  String achievementCompleted(Object completed, Object total) {
    return 'Completed $completed / $total';
  }

  @override
  String get quitProgress => 'Quit Progress';

  @override
  String dayProgress(Object current, Object total) {
    return 'Day $current / $total';
  }

  @override
  String todayGoal(Object count) {
    return 'Today\'s goal: $count cigarettes';
  }

  @override
  String smokedToday(Object count) {
    return 'Smoked today: $count cigarettes';
  }

  @override
  String remainingToday(Object count) {
    return 'Remaining today: $count cigarettes';
  }

  @override
  String get startQuitTitle => 'Start Your Quit Plan';

  @override
  String get startQuitDescription =>
      'Create your personalized quit plan, track your health progress, and get community support.';

  @override
  String get startPlan => 'Start Plan';

  @override
  String get lifestyleTitle => 'Healthy Lifestyle';

  @override
  String get exercise => 'Exercise Challenge';

  @override
  String get healthKnowledge => 'Health Knowledge';

  @override
  String get relaxMusic => 'Relaxing Music';

  @override
  String get ranking => 'Ranking';

  @override
  String get coinBalanceTitle => 'Current Coin Balance';

  @override
  String get nextSmokeCountdown => 'Countdown to Next Smoking Unlock';

  @override
  String get sosHelp => 'SOS Help';

  @override
  String get recordSmoking => 'Record Smoking';

  @override
  String get notUnlocked => 'Not Unlocked';

  @override
  String get coinShop => 'Coin Shop';

  @override
  String get todaySmokingSchedule => 'Today\'s Smoking Schedule';

  @override
  String get smoked => 'Smoked ✓';

  @override
  String get notRecorded => 'Not Recorded';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get todaySaved => 'Saved Today';

  @override
  String get coinUnit => 'Coins';

  @override
  String get forumCategoryAll => 'All';

  @override
  String get forumCategoryCraving => 'Craving';

  @override
  String get forumCategoryStory => 'Quit Stories';

  @override
  String get forumCategoryHealth => 'Health';

  @override
  String get forumCategorySupport => 'Support';

  @override
  String get achievementSpending1000Title => 'Spent 1000 COIN';

  @override
  String get achievementSpending1000Description => 'Spent a total of 1000 COIN';

  @override
  String get achievementSpending1000Progress => 'Have not spent 1000 COIN yet';

  @override
  String get readingTitle => 'Reading';

  @override
  String get readingEmpty => 'No articles available.';

  @override
  String get refresh => 'Refresh';

  @override
  String get readingCoinInsufficient =>
      'Not enough COIN to download this article.';

  @override
  String get downloadFailed => 'Download failed. Please try again later.';

  @override
  String get downloadAndRead => 'Download and Read';

  @override
  String get contentManagementTitle => 'Content Management';

  @override
  String get contentManagementAdd => 'Add Content';

  @override
  String get contentManagementNoData => 'No content data';

  @override
  String get contentManagementEmpty => 'No data available';

  @override
  String get contentManagementEditTitle => 'Edit Content';

  @override
  String contentManagementCategory(Object category) {
    return 'Category: $category';
  }

  @override
  String get contentManagementLanguageCode =>
      'Language code (zh-tw / en / es / all)';

  @override
  String get contentManagementTitleLabel => 'Title';

  @override
  String get contentManagementContentLabel => 'Content';

  @override
  String get contentManagementLinkLabel => 'Link URL';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginWithEmail => 'Sign in with Email';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginPasswordMinLength => 'Password (at least 6 chars)';

  @override
  String get registerNewAccount => 'Register New Account';

  @override
  String get loginAppSloganTitle => 'Quit Smoking Better';

  @override
  String get loginAppSloganSubtitle => 'Support you to quit step by step';

  @override
  String get loginTabSignIn => 'Sign In';

  @override
  String get loginTabRegister => 'Register';

  @override
  String get introSlide1Title => 'Start Your Quit Journey';

  @override
  String get introSlide1Desc =>
      'A science-based quit plan helps you reduce smoking step by step until you quit completely.';

  @override
  String get introSlide2Title => 'Personalized Schedule';

  @override
  String get introSlide2Desc =>
      'Generate a schedule based on your habits and track progress in real time.';

  @override
  String get introSlide3Title => 'Community Support';

  @override
  String get introSlide3Desc =>
      'Join the community, support each other, and ask for help when cravings hit.';

  @override
  String get introSkip => 'Skip';

  @override
  String get introGetStarted => 'Get Started';

  @override
  String get introNext => 'Next ›';

  @override
  String get rankingGlobalTitle => 'Global Ranking';

  @override
  String rankingQuitDays(Object days) {
    return 'Quit for $days days';
  }

  @override
  String readingWaitSeconds(Object seconds) {
    return 'Please read for $seconds more seconds to continue.';
  }

  @override
  String get readingCompletedArticle => 'You have finished this article.';

  @override
  String readingChapterProgress(Object current, Object total) {
    return 'Chapter $current / $total';
  }

  @override
  String get readingCanContinue => 'You can continue to the next chapter';

  @override
  String readingMinSeconds(Object seconds) {
    return 'Please read at least $seconds seconds';
  }

  @override
  String get readingFinish => 'Finish Reading';

  @override
  String get readingContinueNextChapter => 'Continue to Next Chapter';

  @override
  String shopBuyCoins(Object amount) {
    return 'Buy $amount COIN';
  }

  @override
  String get shopCreateForumPost => 'Create Forum Post (-30 COIN)';

  @override
  String get shopVipActive => 'VIP Active';

  @override
  String get shopPremium => 'Premium';

  @override
  String get shopVip => 'VIP';

  @override
  String get forumInsufficientCoinsToGift =>
      'Insufficient COIN. Please go to Coin Shop.';

  @override
  String get forumCreatePostTitle => 'Create New Post';

  @override
  String get forumNeedCoinsToCreatePost =>
      'Insufficient COIN, please purchase in Coin Shop';

  @override
  String get forumCommentSuccessCostOneCoin =>
      'Comment posted, 1 COIN deducted';

  @override
  String get forumCommentFailed => 'Failed to post comment';

  @override
  String get forumCommentNeedsOneCoin => 'Commenting needs 1 COIN';

  @override
  String get forumWatchAdComment => 'Watch Ad to Comment';

  @override
  String get forumGoToCoinShop => 'Go to COIN Shop';

  @override
  String get forumBuyCoin => 'Buy COIN';

  @override
  String get forumWatchingAd => 'Watching ad...';

  @override
  String get forumPostDetailTitle => 'Post Details';

  @override
  String get forumComments => 'Comments';

  @override
  String get forumNoComments => 'No comments yet';

  @override
  String get forumCommentHint => 'Enter comment...';

  @override
  String get scheduleTitle => 'Quit Schedule';

  @override
  String scheduleDayRemaining(Object elapsed, Object remaining) {
    return 'Day $elapsed · $remaining days left';
  }

  @override
  String get scheduleWeeklyView => 'Weekly View';

  @override
  String get scheduleMonthlyView => 'Monthly View';

  @override
  String get scheduleHeaderDay => 'Day';

  @override
  String get scheduleHeaderDate => 'Date';

  @override
  String get scheduleHeaderPlanned => 'Planned';

  @override
  String get scheduleHeaderActual => 'Actual';

  @override
  String get scheduleLegendOnTarget => 'On target';

  @override
  String get scheduleLegendOverTarget => 'Over target';

  @override
  String get scheduleLegendFutureOrEmpty => 'Future/No record';

  @override
  String get setupBasicInfo => 'Basic Info';

  @override
  String get setupEdit => 'Edit';

  @override
  String get setupNone => 'None';

  @override
  String get setupAgeLabel => 'Age';

  @override
  String get setupSmokingYearsLabel => 'Smoking Years';

  @override
  String setupYearsOld(Object value) {
    return '$value years old';
  }

  @override
  String setupYearsValue(Object value) {
    return '$value years';
  }

  @override
  String setupCigarettesPerDay(Object value) {
    return '$value cigarettes/day';
  }

  @override
  String setupPricePerPack(Object value) {
    return '$value per pack';
  }

  @override
  String get setupPlanDays => 'Plan Days';

  @override
  String setupPlanDaysValue(Object days) {
    return '$days days';
  }

  @override
  String get setupFirstSmokeTime => 'First Smoke Time';

  @override
  String get setupLastSmokeTime => 'Last Smoke Time';

  @override
  String get setupViewSchedule => 'View Quit Schedule';

  @override
  String get setupContentManagement => 'Content Management';

  @override
  String get setupConfirmSignOut => 'Confirm Sign Out';

  @override
  String get setupSignOutConfirmMessage =>
      'Your data will stay in cloud and sync on next login.';

  @override
  String get setupSignOut => 'Sign Out';

  @override
  String get setupSignOutAccount => 'Sign Out Account';

  @override
  String get setupEditBasicInfo => 'Edit Basic Info';

  @override
  String get setupSmokingYearsWithYear => 'Smoking Years';

  @override
  String get setupDailyCigarettes => 'Daily Cigarettes';

  @override
  String get setupPricePerPackLabel => 'Cigarette Price (Per Pack)';

  @override
  String setupFirstSmokeWithTime(Object time) {
    return 'First smoke\n$time';
  }

  @override
  String setupLastSmokeWithTime(Object time) {
    return 'Last smoke\n$time';
  }

  @override
  String get setupPlanDaysLabel => 'Plan days:';

  @override
  String setupDaysCompact(Object days) {
    return '${days}d';
  }

  @override
  String setupFormatError(Object error) {
    return 'Format error: $error';
  }

  @override
  String get onboardingNameRequired => 'Please enter your nickname.';

  @override
  String get onboardingFeature1Title => '🌿 Dynamic Quit Schedule';

  @override
  String get onboardingFeature1Desc =>
      'Delay windows dynamically based on your real action time and track smoked records.';

  @override
  String get onboardingFeature2Title => '👑 Coin Shop';

  @override
  String get onboardingFeature2Desc =>
      'Includes coin bundles and VIP support for better motivation.';

  @override
  String get onboardingFeature3Title => '🧡 Community Feed';

  @override
  String get onboardingFeature3Desc =>
      'When cravings hit, ask for help in community and get support.';

  @override
  String get onboardingWelcome => 'Welcome to Quit Smoking Club';

  @override
  String get onboardingCreateProfile => 'Create your profile';

  @override
  String get onboardingNicknameInput => 'Enter your nickname';

  @override
  String get onboardingDailyTarget => 'Daily cigarette target (default 5)';

  @override
  String get onboardingStartJourney => 'Start Your Quit Journey';

  @override
  String get game2048Subtitle => 'Merge numbers by swiping and reach 2048!';

  @override
  String get gameHubBannerTitle => 'Craving? Play games to shift focus!';

  @override
  String get gameHubBannerSubtitle =>
      'Built-in games, offline and ready anytime 🎯';

  @override
  String get gameHubSelectGame => 'Choose a game';

  @override
  String get gameHubOfflineBuiltIn => '✅ Built-in · Offline';

  @override
  String get medicalLibraryTitle => 'Medical Library';

  @override
  String get medicalLibraryEmpty => 'No medical articles available.';

  @override
  String get medicalLibraryLoadFailed =>
      'Failed to load medical articles. Please try again.';

  @override
  String get medicalVip => 'VIP';

  @override
  String get medicalSummaryUnavailable => 'Summary is unavailable.';
}
