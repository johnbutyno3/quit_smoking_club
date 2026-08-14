import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../engines/smoking_engine.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'forum_page.dart';
import 'setup_page.dart';
import 'mitigation_page.dart';
import 'game_hub_page.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../engines/recovery_engine.dart';
import '../engines/achievement_engine.dart';
import '../widgets/achievement_card.dart';
import 'coin_page.dart';
import 'reading_library_page.dart';
import 'medical_library_page.dart';
import 'music_library_page.dart';
import 'story_library_page.dart';
import 'youtube_library_page.dart';
import '../models/user_smoking_status.dart';
import '../widgets/home/home_progress_card.dart';
import '../models/user_role.dart';
import '../usecases/coin/coin_facade_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ThemeColors {
  static const primary = Color(0xFF1B5E20);
  static const accent = Color(0xFF4CAF50);
  static const bgTop = Color(0xFFE8F5E9);
  static const bgBot = Color(0xFFF5F7F6);
  static const cardBg = Colors.white;
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final CoinFacadeUseCase _coinFacade;
  late SmokingEngine engine;
  late AchievementEngine achievement;
  late RecoveryEngine recovery;
  late SmokingState state;
  bool _isLoaded = false;
  Timer? _timer;
  int _myCoins = 0;
  int _cigarettePrice = 120;

  final List<String> _messages = [];

  List<String> _motivationalQuotes(AppLocalizations l10n) => [
    l10n.motivationalQuote1,
    l10n.motivationalQuote2,
    l10n.motivationalQuote3,
    l10n.motivationalQuote4,
    l10n.motivationalQuote5,
  ];

  // ? 3.2.1 ?刻撟??????冽?????
  bool _isVibrating = false;
  String? _activeNotification;
  bool _hasTriggeredUnlockNotify = false;

  @override
  void initState() {
    super.initState();

    _coinFacade = CoinFacadeUseCase();

    _coinFacade.claimDailyLogin();

    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();

    state = SmokingState(
      planStartDate: DateTime.now(),
      startTime: DateTime(now.year, now.month, now.day, 8, 0),
      endTime: DateTime(now.year, now.month, now.day, 22, 0),
      plannedCount: 5,
    );

    final plan = SmokingPlan(
      startTime: state.startTime,
      endTime: state.endTime,
      plannedCount: state.plannedCount,
    );

    engine = SmokingEngine(state, plan);
    recovery = RecoveryEngine(state);
    achievement = AchievementEngine(
      smoking: engine,
      recovery: recovery,
    ); // 閮??冽?蝘?炎?交?西府敶???
    _refreshAchievementProgressContext();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isLoaded) return;

      setState(() {});

      _checkCountdownUnlock();
    });

    _loadStoredData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCoinBalance();
    }
  }

  Future<void> _refreshCoinBalance() async {
    final latestCoins = await _coinFacade.getBalance();
    if (!mounted) return;

    if (_myCoins != latestCoins) {
      setState(() {
        _myCoins = latestCoins;
      });
    }
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final sCount = await StorageFacadeUseCase.getDailyCount();
    final sName = await StorageFacadeUseCase.getUserName();
    final sPrice = await StorageFacadeUseCase.getCigarettePrice();
    final planStartDateStr = await StorageFacadeUseCase.getPlanStartDate();

    final planStartDate = planStartDateStr.isNotEmpty
        ? DateTime.parse(planStartDateStr)
        : now;
    final sCoins = await _coinFacade.getBalance();
    final storedRecords = await StorageFacadeUseCase.getSmokeRecordsForToday();
    final firstTimeStr = await StorageFacadeUseCase.getFirstSmokeTime();
    final lastTimeStr = await StorageFacadeUseCase.getLastSmokeTime();
    final fParts = firstTimeStr.split(':');
    final lParts = lastTimeStr.split(':');
    final firstHour = int.tryParse(fParts[0]) ?? 8;
    final firstMin = int.tryParse(fParts[1]) ?? 0;
    final lastHour = int.tryParse(lParts[0]) ?? 22;
    final lastMin = int.tryParse(lParts[1]) ?? 0;

    if (mounted) {
      setState(() {
        _messages
          ..add(AppLocalizations.of(context)!.welcomeMessage)
          ..add("${AppLocalizations.of(context)!.hello}, $sName!");
        final state = SmokingState(
          planStartDate: planStartDate,

          startTime: DateTime(
            now.year,
            now.month,
            now.day,
            firstHour,
            firstMin,
          ),

          endTime: DateTime(now.year, now.month, now.day, lastHour, lastMin),

          plannedCount: sCount,
          smokeRecords: storedRecords,
          lastSmokeTime: storedRecords.isNotEmpty ? storedRecords.last : null,

          role: UserRole.quitter,
          smokingStatus: SmokingStatus.smoker,
        );
        final plan = SmokingPlan(
          startTime: state.startTime,
          endTime: state.endTime,
          plannedCount: sCount,
        );

        engine = SmokingEngine(state, plan);
        recovery = RecoveryEngine(state);
        achievement = AchievementEngine(smoking: engine, recovery: recovery);
        _myCoins = sCoins;
        _cigarettePrice = sPrice;
        _isLoaded = true;
      });
      _refreshAchievementProgressContext();
    }
  }

  Future<void> _refreshAchievementProgressContext() async {
    final latestCoins = await _coinFacade.getBalance();
    if (!mounted) return;

    setState(() {
      _myCoins = latestCoins;
    });
    final streak = await StorageFacadeUseCase.getLoginStreak();
    final totalSpent = await _coinFacade.getTotalSpentCoins();
    if (!mounted) return;

    setState(() {
      achievement.updateProgressContext(
        loginStreak: streak,
        totalSpentCoins: totalSpent,
      );
    });
  }

  // ? 3.2.1 ?????????刻撟??餃?????
  void _triggerVibration() {
    setState(() => _isVibrating = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isVibrating = false);
    });
  }

  // ? 3.2.1 璈怠?皛?芾???冽敶?
  void _showTopBanner(String msg) {
    _triggerVibration();
    setState(() => _activeNotification = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeNotification = null);
    });
  }

  // ? ?芸??菜葫???堆?蝘銝甇賊?刻?孛?潮
  void _checkCountdownUnlock() {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return;
    final diff = unlockTime.difference(DateTime.now());

    if (diff.inSeconds <= 0) {
      if (!_hasTriggeredUnlockNotify) {
        _hasTriggeredUnlockNotify = true;
        final l10n = AppLocalizations.of(context)!;
        _showTopBanner(l10n.smokingUnlockNotification);
      }
    } else {
      _hasTriggeredUnlockNotify = false;
    }
  }

  Future<void> _smoke() async {
    final now = DateTime.now();
    int matchedIndex = 0;
    for (int i = 0; i < engine.schedule.length; i++) {
      final sTime = engine.schedule[i];
      if (now.hour > sTime.hour ||
          (now.hour == sTime.hour && now.minute >= sTime.minute)) {
        matchedIndex = i;
      }
    }

    if (matchedIndex > engine.totalSmoked) {
      _messages.add(AppLocalizations.of(context)!.smokeSuccessMessage);
    }

    setState(() {
      engine.state = engine.state.addSmoke(now);
    });
    if (engine.remaining == 0) {
      _coinFacade.claimDailyPlanReward();
    }
    await StorageFacadeUseCase.saveSmokeRecords(engine.state.smokeRecords);
  }

  // NOTE: Remaining implementation unchanged.
