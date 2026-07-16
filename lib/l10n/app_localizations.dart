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
  /// **'尚未解鎖'**
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
