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
      'Welcome to Quit Smoking Club! Your challenge is underway.';

  @override
  String get hello => 'Hello';

  @override
  String get dailyCount => 'Daily Cigarettes';

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
  String get gameHub => 'Game Center';

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
  String get countdown => 'Countdown to next unlock';

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
  String get emptyForum => 'No posts yet. Create the first one!';

  @override
  String get sosPost => 'Help Request';

  @override
  String get coinHistory => 'COIN History';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get noTransactionHistory => 'No transaction history';

  @override
  String get purchaseSuccess => 'Purchase successful';

  @override
  String get premiumActivated => 'Premium membership activated';

  @override
  String get achievementDay1Title => 'First Day';

  @override
  String get achievementDay1Description => 'Start your quitting journey';

  @override
  String get achievementDay7Title => 'One Week Completed';

  @override
  String get achievementDay7Description => 'Quit smoking for 7 days';

  @override
  String get achievementDay30Title => 'One Month Completed';

  @override
  String get achievementDay30Description => 'Quit smoking for 30 days';

  @override
  String get achievementMoney1000Title => 'Saved 1000';

  @override
  String get achievementMoney1000Description => 'Saved 1000 in smoking costs';

  @override
  String get achievementRecoveryTitle => 'Health Recovery';

  @override
  String get achievementRecoveryDescription =>
      'Completed the first recovery milestone';

  @override
  String get achievementDay7Progress => '7-day quit goal is not completed yet';

  @override
  String get achievementDay30Progress =>
      '30-day quit goal is not completed yet';

  @override
  String get achievementMoney1000Progress =>
      '1000 savings goal is not completed yet';

  @override
  String get achievementRecoveryProgress =>
      'Recovery milestone is not completed yet';

  @override
  String get todayAchievement => 'Today\'s Achievements';

  @override
  String achievementCompleted(Object completed, Object total) {
    return 'Completed $completed / $total';
  }
}
