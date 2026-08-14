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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStoredData();
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
        final l10n = AppLocalizations.of(context)!;
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
                l10n.cravingReliefChamberTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: double.infinity,
                child: Text(
                  randomQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildTile(
                      Icons.menu_book,
                      l10n.mitigationTileMedical,
                      "Medical",
                    ),
                    _buildTile(
                      Icons.sentiment_satisfied,
                      l10n.mitigationTileShortJokes,
                      "Stories",
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.menu_book_outlined,
                          color: _ThemeColors.accent,
                        ),
                        title: Text(
                          l10n.readingArticleOfflineLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReadingLibraryPage(),
                          ),
                        ),
                      ),
                    ),
                    _buildTile(
                      Icons.video_library,
                      l10n.youtubeVideoLabel,
                      "YouTube",
                    ),
                    _buildTile(Icons.audiotrack, l10n.musicLinkLabel, "Music"),
                    _buildTile(
                      Icons.sports_esports,
                      '5. ${l10n.gameHub} (${l10n.gameHubBuiltInMiniGames})',
                      "GameHub",
                    ),

                    // ===== ?券ㄐ鞎潭??貉???=====

                    // ===== ?隢? Card 敺ㄐ?? =====
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.forum, color: Colors.blue),
                        title: Text(
                          "7. ${l10n.forumGoToForumLobby}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
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

  Widget _buildTile(IconData icon, String label, String page) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: _ThemeColors.accent),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
        onTap: () async {
          if (page == 'Medical') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalLibraryPage(),
              ),
            );
          } else if (page == 'Music') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MusicLibraryPage()),
            );
          } else if (page == 'Stories') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoryLibraryPage()),
            );
          } else if (page == 'YouTube') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const YouTubeLibraryPage(),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MitigationPage(title: page),
              ),
            );
          }
          _loadStoredData();
        },
      ),
    );
  }

  Widget _buildLifestyleCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.white.withAlpha(230),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lifestyleTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLifestyleItem(Icons.directions_run, l10n.exercise),

                _buildLifestyleItem(Icons.menu_book, l10n.healthKnowledge),

                _buildLifestyleItem(Icons.music_note, l10n.relaxMusic),

                _buildLifestyleItem(Icons.leaderboard, l10n.ranking),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleItem(IconData icon, String title) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _ThemeColors.primary, size: 30),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // ? 3.2.1 蝬脤??刻撟??駁????畾?
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
              AppLocalizations.of(context)!.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white.withAlpha(204),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    '$_myCoins COIN',
                    style: const TextStyle(
                      color: _ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.monetization_on, color: Colors.amber),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoinPage()),
                  );
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
                    MaterialPageRoute(builder: (context) => const SetupPage()),
                  );
                  _loadStoredData();
                },
              ),
            ],
          ),
          // ? 3.2.1 ???銝惜嚗??閮??冽?剖?蝒征??
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildPersonalStatusCard(),

                  const SizedBox(height: 16),

                  _buildLifestyleCard(),

                  const SizedBox(height: 16),

                  AchievementCard(achievement: achievement),

                  const SizedBox(height: 20),

                  HomeProgressCard(
                    currentDay:
                        DateTime.now()
                            .difference(engine.state.planStartDate)
                            .inDays +
                        1,

                    totalDays: engine.plan.durationDays,

                    smokedToday: engine.totalSmoked,

                    targetToday: engine.todayPlannedCount,

                    remaining: engine.todayPlannedCount - engine.totalSmoked,
                  ),

                  // 銝?亙??砍隞??
                  Container(
                    height: 95,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _ThemeColors.cardBg.withAlpha(204),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => Text(
                        _messages[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_ThemeColors.primary, Color(0xFF0D3211)],
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: Colors.red.withAlpha(51),
                          ),
                          icon: const Icon(Icons.gpp_bad),
                          label: Text(
                            '? ${l10n.sos}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _triggerSOS,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canSmoke
                                ? _ThemeColors.accent
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: canSmoke ? 4 : 0,
                            shadowColor: _ThemeColors.accent.withAlpha(77),
                          ),
                          icon: Icon(
                            canSmoke
                                ? Icons.check_circle_outline
                                : Icons.lock_outline,
                          ),
                          label: Text(
                            canSmoke ? l10n.recordSmoking : l10n.notUnlocked,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: canSmoke
                              ? () async {
                                  await _smoke();
                                  _triggerVibration();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForumPage(),
                        ),
                      ),
                      child: Text(l10n.forum),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ?憭批輒?函???
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B5E20),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Text('?', style: TextStyle(fontSize: 16)),
                      label: Text(l10n.gameHub),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameHubPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '${l10n.todaySmokingSchedule}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
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

                      bool thisCellIsSmoked = false;
                      if (engine.state.smokeRecords.isNotEmpty) {
                        if (index == engine.schedule.length - 1) {
                          thisCellIsSmoked =
                              now.isAfter(cellTime) &&
                              engine.totalSmoked > index;
                        } else {
                          final nextT = engine.schedule[index + 1];
                          final nextCellTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            nextT.hour,
                            nextT.minute,
                          );
                          thisCellIsSmoked = engine.state.smokeRecords.any(
                            (rec) =>
                                (rec.isAfter(cellTime) ||
                                    rec.isAtSameMomentAs(cellTime)) &&
                                rec.isBefore(nextCellTime),
                          );
                        }
                      }

                      final isPast = now.isAfter(cellTime);
                      final hasSmoked = thisCellIsSmoked;

                      final chipBg = hasSmoked
                          ? Colors.green.shade50
                          : (isPast
                                ? Colors.grey.shade200
                                : Colors.green.shade50);
                      final chipBorder = hasSmoked
                          ? Colors.green.shade100
                          : (isPast
                                ? Colors.grey.shade300
                                : Colors.green.shade100);
                      final textColor = isPast && !hasSmoked
                          ? Colors.grey.shade600
                          : _ThemeColors.primary;
                      final timeStr =
                          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: chipBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              hasSmoked
                                  ? Icons.check_circle
                                  : (isPast
                                        ? Icons.cancel_outlined
                                        : Icons.lock_clock),
                              size: 14,
                              color: hasSmoked
                                  ? Colors.green
                                  : (isPast
                                        ? Colors.grey
                                        : Colors.grey.shade400),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasSmoked
                                  ? l10n.smoked
                                  : (isPast
                                        ? l10n.notRecorded
                                        : l10n.notUnlocked),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: hasSmoked
                                    ? Colors.green
                                    : (isPast
                                          ? Colors.grey
                                          : Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),

              // ? 3.2.1 ?璈怠??芾??冽敶?蝯辣
              if (_activeNotification != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: 1.0,
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0x33FFFFFF),
                            width: 1,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildPersonalStatusCard() {
    switch (state.smokingStatus) {
      case SmokingStatus.smoker:
        return _buildStartQuitCard();

      case SmokingStatus.quitting:
      case SmokingStatus.exSmoker:
      case SmokingStatus.relapsed:
      case SmokingStatus.none:
        return HomeProgressCard(
          currentDay:
              DateTime.now().difference(engine.state.planStartDate).inDays + 1,
          totalDays: engine.plan.durationDays,
          smokedToday: engine.totalSmoked,
          targetToday: engine.todayPlannedCount,
          remaining: engine.todayPlannedCount - engine.totalSmoked,
        );

      case SmokingStatus.supporter:
        return _buildStartQuitCard();
    }
  }

  Widget _buildStartQuitCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white.withAlpha(230),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.startQuitTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              l10n.startQuitDescription,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // 銋?撠??閮??
              },
              child: Text(l10n.startPlan),
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

  int get cigaretteUnitPrice {
    return (_cigarettePrice / 20).round();
  }

  int get todaySavedMoney {
    final savedCount = engine.todayPlannedCount - engine.totalSmoked;

    if (savedCount <= 0) return 0;

    return savedCount * cigaretteUnitPrice;
  }

  String get countdownString {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return "00:00:00";
    final now = DateTime.now();
    final diff = unlockTime.difference(now);
    if (diff.isNegative) return "00:00:00";
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
