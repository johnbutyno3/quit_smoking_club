import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/smoking_state.dart';
import '../engines/smoking_engine.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'forum_page.dart';
import 'setup_page.dart';
import 'game_hub_page.dart';
import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../engines/recovery_engine.dart';
import '../engines/achievement_engine.dart';
import '../widgets/achievement_card.dart';
import 'coin_page.dart';
import 'reading_library_page.dart';
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
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final CoinFacadeUseCase _coinFacade;
  late SmokingEngine engine;
  late AchievementEngine achievement;
  late RecoveryEngine recovery;
  late SmokingState state;
  Timer? _timer;
  bool _isLoaded = false;
  bool _isVibrating = false;
  bool _hasTriggeredUnlockNotify = false;
  int _myCoins = 0;
  String? _activeNotification;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _coinFacade = CoinFacadeUseCase();
    _coinFacade.claimDailyLogin();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    state = SmokingState(
      planStartDate: now,
      startTime: DateTime(now.year, now.month, now.day, 8),
      endTime: DateTime(now.year, now.month, now.day, 22),
      plannedCount: 5,
    );
    final plan = SmokingPlan(startTime: state.startTime, endTime: state.endTime, plannedCount: state.plannedCount);
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
    if (value == AppLifecycleState.resumed) _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final count = await StorageFacadeUseCase.getDailyCount();
    final name = await StorageFacadeUseCase.getUserName();
    final planDate = await StorageFacadeUseCase.getPlanStartDate();
    final coins = await StorageFacadeUseCase.getCoins();
    final records = await StorageFacadeUseCase.getSmokeRecordsForToday();
    final first = (await StorageFacadeUseCase.getFirstSmokeTime()).split(':');
    final last = (await StorageFacadeUseCase.getLastSmokeTime()).split(':');
    final fh = int.tryParse(first[0]) ?? 8;
    final fm = int.tryParse(first.length > 1 ? first[1] : '0') ?? 0;
    final lh = int.tryParse(last[0]) ?? 22;
    final lm = int.tryParse(last.length > 1 ? last[1] : '0') ?? 0;
    if (!mounted) return;
    final loadedState = SmokingState(
      planStartDate: planDate.isNotEmpty ? DateTime.parse(planDate) : now,
      startTime: DateTime(now.year, now.month, now.day, fh, fm),
      endTime: DateTime(now.year, now.month, now.day, lh, lm),
      plannedCount: count,
      smokeRecords: records,
      lastSmokeTime: records.isNotEmpty ? records.last : null,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );
    final plan = SmokingPlan(startTime: loadedState.startTime, endTime: loadedState.endTime, plannedCount: count);
    setState(() {
      state = loadedState;
      engine = SmokingEngine(loadedState, plan);
      recovery = RecoveryEngine(loadedState);
      achievement = AchievementEngine(smoking: engine, recovery: recovery);
      _myCoins = coins;
      _isLoaded = true;
      if (_messages.isEmpty) {
        _messages.add(AppLocalizations.of(context)!.welcomeMessage);
        if (name.isNotEmpty) _messages.add('${AppLocalizations.of(context)!.hello}, $name!');
      }
    });
    await _refreshAchievementProgressContext();
  }

  Future<void> _refreshAchievementProgressContext() async {
    await _coinFacade.getBalance();
    final streak = await StorageFacadeUseCase.getLoginStreak();
    final spent = await _coinFacade.getTotalSpentCoins();
    if (!mounted) return;
    setState(() => achievement.updateProgressContext(loginStreak: streak, totalSpentCoins: spent));
  }

  void _triggerVibration() {
    setState(() => _isVibrating = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isVibrating = false);
    });
  }

  void _showTopBanner(String message) {
    _triggerVibration();
    setState(() => _activeNotification = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeNotification = null);
    });
  }

  void _checkCountdownUnlock() {
    final unlock = engine.nextUnlockTime;
    if (unlock == null) return;
    if (unlock.isAfter(DateTime.now())) {
      _hasTriggeredUnlockNotify = false;
      return;
    }
    if (!_hasTriggeredUnlockNotify) {
      _hasTriggeredUnlockNotify = true;
      _showTopBanner(AppLocalizations.of(context)!.smokingUnlockNotification);
    }
  }

  Future<void> _smoke() async {
    if (!canSmoke) return;
    final now = DateTime.now();
    setState(() {
      engine.state = engine.state.addSmoke(now);
      _messages.add(AppLocalizations.of(context)!.smokeSuccessMessage);
    });
    if (engine.remaining == 0) await _coinFacade.claimDailyPlanReward();
    await StorageFacadeUseCase.saveSmokeRecords(engine.state.smokeRecords);
  }

  void _triggerSOS() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _messages.add(l10n.cravingWarningMessage);
      _messages.add(l10n.friendEncouragementMessage);
    });
    final quotes = [l10n.motivationalQuote1, l10n.motivationalQuote2, l10n.motivationalQuote3, l10n.motivationalQuote4, l10n.motivationalQuote5];
    final quote = quotes[Random().nextInt(quotes.length)];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .55,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: _ThemeColors.bgBot, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Text(l10n.cravingReliefChamberTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(quote, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Expanded(child: ListView(children: [
            _reliefTile(Icons.menu_book, l10n.mitigationTileMedical, const ReadingLibraryPage()),
            _reliefTile(Icons.sentiment_satisfied, l10n.mitigationTileShortJokes, const ReadingLibraryPage()),
            _reliefTile(Icons.video_library, l10n.youtubeVideoLabel, const YouTubeLibraryPage()),
            _reliefTile(Icons.sports_esports, l10n.gameHub, const GameHubPage()),
            ListTile(leading: const Icon(Icons.forum, color: Colors.blue), title: Text(l10n.forum, style: const TextStyle(fontSize: 16)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ForumPage())); }),
          ])),
        ]),
      ),
    );
  }

  Widget _reliefTile(IconData icon, String title, Widget page) => ListTile(
    leading: Icon(icon, color: _ThemeColors.accent),
    title: Text(title, style: const TextStyle(fontSize: 16)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
  );

  void _showMessages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(child: SizedBox(
        height: MediaQuery.of(context).size.height * .65,
        child: Column(children: [
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text(_messages[i], style: const TextStyle(fontSize: 16, height: 1.4))),
          )),
        ]),
      )),
    );
  }

  void _showSchedule() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.todaySmokingSchedule, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...engine.schedule.map((time) => ListTile(dense: true, leading: const Icon(Icons.schedule, color: _ThemeColors.accent), title: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16)))),
        ]),
      )),
    );
  }

  Widget _buildUnlockCard() {
    final unlock = engine.nextUnlockTime;
    final now = DateTime.now();
    double progress = 1;
    if (unlock != null) {
      final previous = engine.totalSmoked == 0 ? engine.state.startTime : engine.schedule[min(engine.totalSmoked - 1, engine.schedule.length - 1)];
      final total = unlock.difference(previous).inSeconds;
      final left = max(0, unlock.difference(now).inSeconds);
      if (total > 0) progress = (1 - left / total).clamp(0.0, 1.0);
    }
    final unlocked = unlock == null || !unlock.isAfter(now);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: unlocked ? () async { await _smoke(); _triggerVibration(); } : null,
        child: Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(unlocked ? l10n.recordSmoking : l10n.nextSmokeCountdown, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(width: 150, height: 150, child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 10, backgroundColor: Colors.grey.shade200, color: _ThemeColors.accent)),
            Text(countdownString, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ])),
          const SizedBox(height: 8),
          if (unlocked) Text(l10n.recordSmoking, style: const TextStyle(fontSize: 14, color: _ThemeColors.primary, fontWeight: FontWeight.bold)),
        ])),
      ),
    );
  }

  Widget _buildProgressSummary() => Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
      AchievementCard(achievement: achievement),
      const SizedBox(height: 4),
      HomeProgressCard(
        currentDay: DateTime.now().difference(engine.state.planStartDate).inDays + 1,
        totalDays: engine.plan.durationDays,
        smokedToday: engine.totalSmoked,
        targetToday: engine.todayPlannedCount,
        remaining: max(0, engine.todayPlannedCount - engine.totalSmoked),
      ),
    ])),
  );

  Widget _bottomAction(IconData icon, String label, VoidCallback action) => Expanded(child: InkWell(
    onTap: action,
    borderRadius: BorderRadius.circular(14),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 21, color: _ThemeColors.primary),
      const SizedBox(height: 3),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    ])),
  ));

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5), child: Row(children: [
        _bottomAction(Icons.sos, l10n.sos, _triggerSOS),
        _bottomAction(Icons.forum_outlined, l10n.forum, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForumPage()))),
        _bottomAction(Icons.article_outlined, l10n.readingArticleOfflineLabel, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingLibraryPage()))),
        _bottomAction(Icons.video_library_outlined, l10n.youtubeVideoLabel, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YouTubeLibraryPage()))),
        _bottomAction(Icons.sports_esports_outlined, l10n.gameHub, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameHubPage()))),
        _bottomAction(Icons.schedule, l10n.todaySmokingSchedule, _showSchedule),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 50),
      padding: EdgeInsets.only(left: _isVibrating ? 8 : 0, right: _isVibrating ? 0 : 8),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_ThemeColors.bgTop, _ThemeColors.bgBot])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white.withAlpha(204),
            elevation: 0,
            actions: [
              Padding(padding: const EdgeInsets.only(right: 2), child: Center(child: Text('$_myCoins', style: const TextStyle(color: _ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 16)))),
              IconButton(icon: const Icon(Icons.monetization_on, color: Colors.amber), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinPage()))),
              IconButton(icon: const Icon(Icons.settings_outlined, color: _ThemeColors.primary), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupPage())); _loadStoredData(); }),
            ],
          ),
          body: Stack(children: [
            ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 18), children: [
              Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(flex: 5, child: _buildUnlockCard()),
                const SizedBox(width: 12),
                Expanded(flex: 5, child: _buildProgressSummary()),
              ]),
              const SizedBox(height: 14),
              InkWell(
                onTap: _showMessages,
                borderRadius: BorderRadius.circular(18),
                child: Card(margin: EdgeInsets.zero, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
                  const Icon(Icons.chat_bubble_outline, color: _ThemeColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_messages.isEmpty ? l10n.welcomeMessage : _messages.last, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w500))),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ]))),
              ),
              const SizedBox(height: 14),
              _buildBottomBar(),
            ]),
            if (_activeNotification != null) Positioned(top: 12, left: 16, right: 16, child: Material(elevation: 8, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: _ThemeColors.primary, borderRadius: BorderRadius.circular(14)), child: Row(children: [
              const Icon(Icons.notifications_active, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(child: Text(_activeNotification!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ]))))
          ]),
        ),
      ),
    );
  }

  bool get canSmoke => engine.totalSmoked < engine.state.plannedCount && engine.availableSlots > engine.totalSmoked;

  String get countdownString {
    final unlock = engine.nextUnlockTime;
    if (unlock == null) return '00:00:00';
    final diff = unlock.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';
    return '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
