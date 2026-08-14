import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../engines/smoking_engine.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'forum_page.dart';
import 'shop_page.dart';
import 'setup_page.dart';
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
  static const glassBorder = Color(0x33FFFFFF);
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
  bool _isVibrating = false;
  String? _activeNotification;
  bool _hasTriggeredUnlockNotify = false;
  final List<String> _messages = [];

  List<String> _motivationalQuotes(AppLocalizations l10n) => [
        l10n.motivationalQuote1,
        l10n.motivationalQuote2,
        l10n.motivationalQuote3,
        l10n.motivationalQuote4,
        l10n.motivationalQuote5,
      ];

  @override
  void initState() {
    super.initState();
    _coinFacade = CoinFacadeUseCase();
    _coinFacade.claimDailyLogin();
    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();
    state = SmokingState(
      planStartDate: now,
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
    achievement = AchievementEngine(smoking: engine, recovery: recovery);

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
  void didChangeAppLifecycleState(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed) {
      _loadStoredData();
    }
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final sCount = await StorageFacadeUseCase.getDailyCount();
    final sName = await StorageFacadeUseCase.getUserName();
    final sPrice = await StorageFacadeUseCase.getCigarettePrice();
    final planStartDateStr = await StorageFacadeUseCase.getPlanStartDate();
    final sCoins = await StorageFacadeUseCase.getCoins();
    final storedRecords =
        await StorageFacadeUseCase.getSmokeRecordsForToday();
    final firstTimeStr = await StorageFacadeUseCase.getFirstSmokeTime();
    final lastTimeStr = await StorageFacadeUseCase.getLastSmokeTime();

    final fParts = firstTimeStr.split(':');
    final lParts = lastTimeStr.split(':');
    final firstHour = int.tryParse(fParts[0]) ?? 8;
    final firstMin = int.tryParse(fParts.length > 1 ? fParts[1] : '0') ?? 0;
    final lastHour = int.tryParse(lParts[0]) ?? 22;
    final lastMin = int.tryParse(lParts.length > 1 ? lParts[1] : '0') ?? 0;

    if (!mounted) return;

    final loadedState = SmokingState(
      planStartDate: planStartDateStr.isNotEmpty
          ? DateTime.parse(planStartDateStr)
          : now,
      startTime: DateTime(
        now.year,
        now.month,
        now.day,
        firstHour,
        firstMin,
      ),
      endTime: DateTime(
        now.year,
        now.month,
        now.day,
        lastHour,
        lastMin,
      ),
      plannedCount: sCount,
      smokeRecords: storedRecords,
      lastSmokeTime:
          storedRecords.isNotEmpty ? storedRecords.last : null,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );

    final plan = SmokingPlan(
      startTime: loadedState.startTime,
      endTime: loadedState.endTime,
      plannedCount: sCount,
    );

    setState(() {
      state = loadedState;
      engine = SmokingEngine(loadedState, plan);
      recovery = RecoveryEngine(loadedState);
      achievement = AchievementEngine(smoking: engine, recovery: recovery);
      _myCoins = sCoins;
      _cigarettePrice = sPrice;
      _isLoaded = true;

      if (_messages.isEmpty) {
        _messages.add(AppLocalizations.of(context)!.welcomeMessage);
        if (sName.isNotEmpty) {
          _messages.add('${AppLocalizations.of(context)!.hello}, $sName!');
        }
      }
    });

    await _refreshAchievementProgressContext();
  }

  Future<void> _refreshAchievementProgressContext() async {
    await _coinFacade.getBalance();
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

  void _triggerVibration() {
    setState(() => _isVibrating = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isVibrating = false);
    });
  }

  void _showTopBanner(String msg) {
    _triggerVibration();
    setState(() => _activeNotification = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeNotification = null);
    });
  }

  void _checkCountdownUnlock() {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return;
    final diff = unlockTime.difference(DateTime.now());

    if (diff.inSeconds <= 0) {
      if (!_hasTriggeredUnlockNotify) {
        _hasTriggeredUnlockNotify = true;
        _showTopBanner(
          AppLocalizations.of(context)!.smokingUnlockNotification,
        );
      }
    } else {
      _hasTriggeredUnlockNotify = false;
    }
  }

  Future<void> _smoke() async {
    if (!canSmoke) return;

    final now = DateTime.now();
    setState(() {
      engine.state = engine.state.addSmoke(now);
      _messages.add(AppLocalizations.of(context)!.smokeSuccessMessage);
    });

    if (engine.remaining == 0) {
      await _coinFacade.claimDailyPlanReward();
    }

    await StorageFacadeUseCase.saveSmokeRecords(engine.state.smokeRecords);
  }

  void _triggerSOS() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _messages.add(l10n.cravingWarningMessage);
      _messages.add(l10n.friendEncouragementMessage);
    });

    final quotes = _motivationalQuotes(l10n);
    final randomQuote = quotes[Random().nextInt(quotes.length)];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final modalL10n = AppLocalizations.of(context)!;
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: _ThemeColors.bgBot,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                modalL10n.cravingReliefChamberTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: double.infinity,
                child: Text(
                  randomQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildReliefTile(
                      Icons.menu_book,
                      modalL10n.mitigationTileMedical,
                      const MedicalLibraryPage(),
                    ),
                    _buildReliefTile(
                      Icons.sentiment_satisfied,
                      modalL10n.mitigationTileShortJokes,
                      const StoryLibraryPage(),
                    ),
                    _buildReliefTile(
                      Icons.menu_book_outlined,
                      modalL10n.readingArticleOfflineLabel,
                      const ReadingLibraryPage(),
                    ),
                    _buildReliefTile(
                      Icons.video_library,
                      modalL10n.youtubeVideoLabel,
                      const YouTubeLibraryPage(),
                    ),
                    _buildReliefTile(
                      Icons.audiotrack,
                      modalL10n.musicLinkLabel,
                      const MusicLibraryPage(),
                    ),
                    _buildReliefTile(
                      Icons.sports_esports,
                      modalL10n.gameHub,
                      const GameHubPage(),
                    ),
                    Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const Icon(Icons.forum, color: Colors.blue),
                        title: Text(
                          modalL10n.forumGoToForumLobby,
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForumPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReliefTile(IconData icon, String label, Widget page) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: _ThemeColors.accent),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }

  void _showMessages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.70,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: Text('No messages'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(18),
                        itemCount: _messages.length,
                        itemBuilder: (_, index) => Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              _messages[index],
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSchedule() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaySmokingSchedule,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: List.generate(engine.schedule.length, (index) {
                      final t = engine.schedule[index];
                      final now = DateTime.now();
                      final cellTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        t.hour,
                        t.minute,
                      );
                      final isPast = now.isAfter(cellTime);
                      final hasSmoked = index < engine.totalSmoked;
                      return ListTile(
                        leading: Icon(
                          hasSmoked
                              ? Icons.check_circle
                              : isPast
                                  ? Icons.cancel_outlined
                                  : Icons.lock_clock,
                          color: hasSmoked
                              ? Colors.green
                              : isPast
                                  ? Colors.grey
                                  : _ThemeColors.accent,
                        ),
                        title: Text(
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          hasSmoked
                              ? l10n.smoked
                              : isPast
                                  ? l10n.notRecorded
                                  : l10n.notUnlocked,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockCard() {
    final unlockTime = engine.nextUnlockTime;
    final now = DateTime.now();
    double progress = 1.0;

    if (unlockTime != null) {
      final previousTime = engine.totalSmoked == 0
          ? engine.state.startTime
          : engine.schedule[
              min(engine.totalSmoked - 1, engine.schedule.length - 1)
            ];
      final totalSeconds =
          unlockTime.difference(previousTime).inSeconds;
      final remainingSeconds =
          max(0, unlockTime.difference(now).inSeconds);
      if (totalSeconds > 0) {
        progress =
            (1 - remainingSeconds / totalSeconds).clamp(0.0, 1.0);
      }
    }

    final unlocked = unlockTime == null || !unlockTime.isAfter(now);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.white.withAlpha(235),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: unlocked
            ? () async {
                await _smoke();
                _triggerVibration();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                unlocked
                    ? l10n.recordSmoking
                    : l10n.nextSmokeCountdown,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 155,
                height: 155,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 11,
                        backgroundColor: Colors.grey.shade200,
                        color: _ThemeColors.accent,
                      ),
                    ),
                    Text(
                      countdownString,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                unlocked
                    ? l10n.recordSmoking
                    : l10n.nextSmokeCountdown,
                style: TextStyle(
                  fontSize: 14,
                  color: unlocked
                      ? _ThemeColors.primary
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressScheduleCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white.withAlpha(235),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AchievementCard(achievement: achievement),
            const SizedBox(height: 6),
            HomeProgressCard(
              currentDay:
                  DateTime.now().difference(engine.state.planStartDate).inDays + 1,
              totalDays: engine.plan.durationDays,
              smokedToday: engine.totalSmoked,
              targetToday: engine.todayPlannedCount,
              remaining:
                  max(0, engine.todayPlannedCount - engine.totalSmoked),
            ),
            const Divider(height: 18),
            Text(
              l10n.todaySmokingSchedule,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(engine.schedule.length, (index) {
                final t = engine.schedule[index];
                final now = DateTime.now();
                final cellTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  t.hour,
                  t.minute,
                );
                final isPast = now.isAfter(cellTime);
                final hasSmoked = index < engine.totalSmoked;
                final timeStr =
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasSmoked
                        ? Colors.green.shade50
                        : isPast
                            ? Colors.grey.shade200
                            : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasSmoked
                          ? Colors.green.shade100
                          : isPast
                              ? Colors.grey.shade300
                              : Colors.green.shade100,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isPast && !hasSmoked
                              ? Colors.grey.shade600
                              : _ThemeColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        hasSmoked
                            ? Icons.check_circle
                            : isPast
                                ? Icons.cancel_outlined
                                : Icons.lock_clock,
                        size: 12,
                        color: hasSmoked
                            ? Colors.green
                            : isPast
                                ? Colors.grey
                                : Colors.grey.shade400,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ThemeColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback action) {
    return Expanded(
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: _ThemeColors.primary),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Row(
          children: [
            _bottomAction(Icons.sos, l10n.sos, _triggerSOS),
            _bottomAction(
              Icons.forum_outlined,
              l10n.forum,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForumPage()),
              ),
            ),
            _bottomAction(
              Icons.article_outlined,
              l10n.readingArticleOfflineLabel,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReadingLibraryPage(),
                ),
              ),
            ),
            _bottomAction(
              Icons.video_library_outlined,
              l10n.youtubeVideoLabel,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const YouTubeLibraryPage(),
                ),
              ),
            ),
            _bottomAction(
              Icons.sports_esports_outlined,
              l10n.gameHub,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameHubPage()),
              ),
            ),
            _bottomAction(
              Icons.schedule,
              l10n.todaySmokingSchedule,
              _showSchedule,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 50),
      padding: EdgeInsets.only(
        left: _isVibrating ? 8.0 : 0.0,
        right: _isVibrating ? 0.0 : 8.0,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_ThemeColors.bgTop, _ThemeColors.bgBot],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white.withAlpha(204),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Center(
                  child: Text(
                    '$_myCoins',
                    style: const TextStyle(
                      color: _ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoinPage()),
                  );
                  _loadStoredData();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: _ThemeColors.primary,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SetupPage()),
                  );
                  _loadStoredData();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildUnlockCard()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildProgressScheduleCard()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _showMessages,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 105,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _ThemeColors.cardBg.withAlpha(220),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline,
                                      color: _ThemeColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.appTitle,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Expanded(
                                  child: _messages.isEmpty
                                      ? const SizedBox.shrink()
                                      : Text(
                                          _messages.last,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.35,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                l10n.smokedCount,
                                l10n.cigarettesCount(engine.totalSmoked),
                                Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStatCard(
                                l10n.remaining,
                                l10n.cigarettesCount(engine.remaining),
                                _ThemeColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildStatCard(
                          l10n.todaySaved,
                          l10n.currencyAmount(todaySavedMoney.toString()),
                          Colors.green,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                _ThemeColors.primary,
                                Color(0xFF0D3211),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _ThemeColors.primary.withAlpha(77),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.nextSmokeCountdown,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE8F5E9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                countdownString,
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: _buildBottomBar(),
                  ),
                ],
              ),
              if (_activeNotification != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _ThemeColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _activeNotification!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? get nextSmokeTime {
    final now = DateTime.now();
    for (final t in engine.schedule) {
      if (t.isAfter(now)) return t;
    }
    return null;
  }

  bool get canSmoke {
    if (engine.totalSmoked >= engine.state.plannedCount) {
      return false;
    }
    return engine.availableSlots > engine.totalSmoked;
  }

  int get cigaretteUnitPrice => (_cigarettePrice / 20).round();

  int get todaySavedMoney {
    final savedCount = engine.todayPlannedCount - engine.totalSmoked;
    if (savedCount <= 0) return 0;
    return savedCount * cigaretteUnitPrice;
  }

  String get countdownString {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return '00:00:00';
    final diff = unlockTime.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}