import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../engines/smoking_engine.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'forum_page.dart';
import 'shop_page.dart';
import 'setup_page.dart';
import 'mitigation_page.dart';
import 'game_hub_page.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../engines/recovery_engine.dart';
import '../engines/achievement_engine.dart';
import '../widgets/achievement_card.dart';
import 'quit_plan_page.dart';
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

  final List<String> _messages = [];

  List<String> _motivationalQuotes(AppLocalizations l10n) => [
    l10n.motivationalQuote1,
    l10n.motivationalQuote2,
    l10n.motivationalQuote3,
    l10n.motivationalQuote4,
    l10n.motivationalQuote5,
  ];

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
    achievement = AchievementEngine(smoking: engine, recovery: recovery);
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
    final planStartDate = planStartDateStr.isNotEmpty ? DateTime.parse(planStartDateStr) : now;
    final sCoins = await StorageFacadeUseCase.getCoins();
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
          startTime: DateTime(now.year, now.month, now.day, firstHour, firstMin),
          endTime: DateTime(now.year, now.month, now.day, lastHour, lastMin),
          plannedCount: sCount,
          smokeRecords: storedRecords,
          lastSmokeTime: storedRecords.isNotEmpty ? storedRecords.last : null,
          role: UserRole.quitter,
          smokingStatus: SmokingStatus.smoker,
        );
        final plan = SmokingPlan(startTime: state.startTime, endTime: state.endTime, plannedCount: sCount);
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
    await _coinFacade.getBalance();
    final streak = await StorageFacadeUseCase.getLoginStreak();
    final totalSpent = await _coinFacade.getTotalSpentCoins();
    if (!mounted) return;
    setState(() {
      achievement.updateProgressContext(loginStreak: streak, totalSpentCoins: totalSpent);
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
        final l10n = AppLocalizations.of(context)!;
        _showTopBanner(l10n.smokingUnlockNotification);
      }
    } else {
      _hasTriggeredUnlockNotify = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadStoredData();
  }

  Future<void> _smoke() async {
    final now = DateTime.now();
    int matchedIndex = 0;
    for (int i = 0; i < engine.schedule.length; i++) {
      final sTime = engine.schedule[i];
      if (now.hour > sTime.hour || (now.hour == sTime.hour && now.minute >= sTime.minute)) matchedIndex = i;
    }
    if (matchedIndex > engine.totalSmoked) _messages.add(AppLocalizations.of(context)!.smokeSuccessMessage);
    setState(() => engine.state = engine.state.addSmoke(now));
    if (engine.remaining == 0) _coinFacade.claimDailyPlanReward();
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
          decoration: const BoxDecoration(color: _ThemeColors.bgBot, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(l10n.cravingReliefChamberTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                width: double.infinity,
                child: Text("「$randomQuote」", textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildTile(Icons.menu_book, l10n.mitigationTileMedical, 'Medical'),
                    _buildTile(Icons.sentiment_satisfied, l10n.mitigationTileShortJokes, 'Stories'),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.menu_book_outlined, color: _ThemeColors.accent),
                        title: Text(l10n.readingArticleOfflineLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingLibraryPage())),
                      ),
                    ),
                    _buildTile(Icons.video_library, l10n.youtubeVideoLabel, 'YouTube'),
                    _buildTile(Icons.audiotrack, l10n.musicLinkLabel, 'Music'),
                    _buildTile(Icons.sports_esports, '5. ${l10n.gameHub} (${l10n.gameHubBuiltInMiniGames})', 'GameHub'),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.event_note, color: Colors.green),
                        title: Text('6. ${l10n.quitPlan}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                        onTap: () async {
                          Navigator.pop(context);
                          final newPlan = await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuitPlanPage()));
                          if (newPlan != null && newPlan is SmokingPlan) {
                            final newState = SmokingState(planStartDate: DateTime.now(), startTime: newPlan.startTime, endTime: newPlan.endTime, plannedCount: newPlan.plannedCount);
                            setState(() {
                              engine = SmokingEngine(newState, newPlan);
                              recovery = RecoveryEngine(newState);
                              achievement = AchievementEngine(smoking: engine, recovery: recovery);
                            });
                            _refreshAchievementProgressContext();
                          }
                        },
                      ),
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.forum, color: Colors.blue),
                        title: Text('7. ${l10n.forumGoToForumLobby}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ForumPage()));
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
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        onTap: () async {
          if (page == 'Medical') {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalLibraryPage()));
          } else if (page == 'Music') {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicLibraryPage()));
          } else if (page == 'Stories') {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryLibraryPage()));
          } else if (page == 'YouTube') {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const YouTubeLibraryPage()));
          } else if (page == 'GameHub') {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const GameHubPage()));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => MitigationPage(title: page)));
          }
          if (mounted) _loadStoredData();
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
            Text(l10n.lifestyleTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildLifestyleItem(Icons.directions_run, l10n.exercise),
              _buildLifestyleItem(Icons.menu_book, l10n.healthKnowledge),
              _buildLifestyleItem(Icons.music_note, l10n.relaxMusic),
              _buildLifestyleItem(Icons.leaderboard, l10n.ranking),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleItem(IconData icon, String title) {
    return Expanded(child: Column(children: [
      Icon(icon, color: _ThemeColors.primary, size: 30),
      const SizedBox(height: 8),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 50),
      padding: EdgeInsets.only(left: _isVibrating ? 8.0 : 0.0, right: _isVibrating ? 0.0 : 8.0),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_ThemeColors.bgTop, _ThemeColors.bgBot])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white.withAlpha(204),
            elevation: 0,
            actions: [
              Padding(padding: const EdgeInsets.only(right: 8), child: Center(child: Text('🪙 $_myCoins', style: const TextStyle(color: _ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 16)))),
            ],
          ),
          body: _isLoaded ? _buildBody(l10n) : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(16), children: [
        _buildLifestyleCard(),
        const SizedBox(height: 16),
        HomeProgressCard(engine: engine, l10n: l10n),
        const SizedBox(height: 16),
        AchievementCard(achievement: achievement),
      ]),
      if (_activeNotification != null)
        Positioned(top: 12, left: 12, right: 12, child: Material(elevation: 6, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(12), child: Text(_activeNotification!)))),
    ]);
  }
}
