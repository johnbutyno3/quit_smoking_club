import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../models/user_role.dart';
import '../models/user_smoking_status.dart';
import '../usecases/coin/coin_facade_usecase.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import 'coin_page.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'medical_library_page.dart';
import 'reading_library_page.dart';
import 'setup_page.dart';
import 'story_library_page.dart';
import 'youtube_library_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ThemeColors {
  static const primary = Color(0xFF1B5E20);
  static const accent = Color(0xFF4CAF50);
  static const bgTop = Color(0xFFE8F5E9);
  static const bgBottom = Color(0xFFF7F9F8);
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final CoinFacadeUseCase _coinFacade;
  late SmokingEngine engine;
  late SmokingState state;

  Timer? _timer;
  bool _isLoaded = false;
  int _myCoins = 0;
  String _userName = '';
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _coinFacade = CoinFacadeUseCase();
    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();
    state = SmokingState(
      planStartDate: now,
      startTime: DateTime(now.year, now.month, now.day, 8),
      endTime: DateTime(now.year, now.month, now.day, 22),
      plannedCount: 5,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );
    engine = SmokingEngine(
      state,
      SmokingPlan(
        startTime: state.startTime,
        endTime: state.endTime,
        plannedCount: state.plannedCount,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isLoaded) return;
      setState(() {});
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
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _loadStoredData();
    }
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final count = await StorageFacadeUseCase.getDailyCount();
    final name = await StorageFacadeUseCase.getUserName();
    final planStart = await StorageFacadeUseCase.getPlanStartDate();
    final records = await StorageFacadeUseCase.getSmokeRecordsForToday();
    final first = await StorageFacadeUseCase.getFirstSmokeTime();
    final last = await StorageFacadeUseCase.getLastSmokeTime();
    final coins = await StorageFacadeUseCase.getCoins();

    final firstParts = first.split(':');
    final lastParts = last.split(':');
    final firstHour = int.tryParse(firstParts.first) ?? 8;
    final firstMinute = int.tryParse(firstParts.length > 1 ? firstParts[1] : '0') ?? 0;
    final lastHour = int.tryParse(lastParts.first) ?? 22;
    final lastMinute = int.tryParse(lastParts.length > 1 ? lastParts[1] : '0') ?? 0;

    if (!mounted) return;

    final loadedState = SmokingState(
      planStartDate: planStart.isNotEmpty ? DateTime.parse(planStart) : now,
      startTime: DateTime(now.year, now.month, now.day, firstHour, firstMinute),
      endTime: DateTime(now.year, now.month, now.day, lastHour, lastMinute),
      plannedCount: count,
      smokeRecords: records,
      lastSmokeTime: records.isNotEmpty ? records.last : null,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );
    final loadedPlan = SmokingPlan(
      startTime: loadedState.startTime,
      endTime: loadedState.endTime,
      plannedCount: count,
    );

    setState(() {
      state = loadedState;
      engine = SmokingEngine(loadedState, loadedPlan);
      _userName = name;
      _myCoins = coins;
      _isLoaded = true;

      if (_messages.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        _messages.add(l10n.welcomeMessage);
      }
    });

    await _coinFacade.getBalance();
  }

  Future<void> _recordSmoke() async {
    if (!canSmoke) return;
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      engine.state = engine.state.addSmoke(now);
      _messages.add(l10n.smokeSuccessMessage);
    });

    if (engine.remaining == 0) {
      await _coinFacade.claimDailyPlanReward();
    }
    await StorageFacadeUseCase.saveSmokeRecords(engine.state.smokeRecords);
    if (!mounted) return;
    await _loadStoredData();
  }

  bool get canSmoke {
    if (engine.totalSmoked >= engine.todayPlannedCount) return false;
    final unlock = engine.nextUnlockTime;
    return unlock == null || !DateTime.now().isBefore(unlock);
  }

  double get unlockProgress {
    final unlock = engine.nextUnlockTime;
    if (unlock == null) return 1;

    final start = engine.state.lastSmokeTime ?? engine.state.startTime;
    final total = unlock.difference(start).inSeconds;
    if (total <= 0) return 1;

    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String get countdownString {
    final unlock = engine.nextUnlockTime;
    if (unlock == null) return '00:00:00';

    final diff = unlock.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _showMessageHistory() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .72,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(fontSize: 18, height: 1.5),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaySmokingSchedule,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: engine.schedule.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final time = engine.schedule[index];
                      final now = DateTime.now();
                      final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                      final smoked = index < engine.totalSmoked;
                      final past = now.isAfter(scheduled);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          smoked
                              ? Icons.check_circle
                              : past
                                  ? Icons.cancel_outlined
                                  : Icons.lock_clock,
                          color: smoked
                              ? Colors.green
                              : past
                                  ? Colors.grey
                                  : _ThemeColors.accent,
                        ),
                        title: Text(
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          smoked
                              ? l10n.smoked
                              : past
                                  ? l10n.notRecorded
                                  : l10n.notUnlocked,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (mounted) await _loadStoredData();
  }

  void _showSOS() {
    final l10n = AppLocalizations.of(context)!;
    final quotes = <String>[
      l10n.motivationalQuote1,
      l10n.motivationalQuote2,
      l10n.motivationalQuote3,
      l10n.motivationalQuote4,
      l10n.motivationalQuote5,
    ];
    final quote = quotes[Random().nextInt(quotes.length)];

    setState(() {
      _messages.add(l10n.cravingWarningMessage);
      _messages.add(l10n.friendEncouragementMessage);
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cravingReliefChamberTitle,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                quote,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _sosAction(l10n.mitigationTileMedical, () => _openPage(const MedicalLibraryPage())),
                  _sosAction(l10n.mitigationTileShortJokes, () => _openPage(const StoryLibraryPage())),
                  _sosAction(l10n.readingArticleOfflineLabel, () => _openPage(const ReadingLibraryPage())),
                  _sosAction(l10n.youtubeVideoLabel, () => _openPage(const YouTubeLibraryPage())),
                  _sosAction(l10n.gameHub, () => _openPage(const GameHubPage())),
                  _sosAction(l10n.forum, () => _openPage(const ForumPage())),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sosAction(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildConversationCard() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _showMessageHistory,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: _ThemeColors.bgTop,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, color: _ThemeColors.primary),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                _userName.isEmpty
                    ? l10n.welcomeMessage
                    : '${l10n.hello}, $_userName\n${l10n.welcomeMessage}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, height: 1.4),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockCard() {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = canSmoke;

    return InkWell(
      onTap: unlocked ? _recordSmoke : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 250,
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              unlocked ? l10n.recordSmoking : l10n.nextSmokeCountdown,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: unlocked ? _ThemeColors.primary : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 168,
                    height: 168,
                    child: CircularProgressIndicator(
                      value: unlockProgress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: unlocked ? _ThemeColors.accent : _ThemeColors.primary,
                    ),
                  ),
                  Text(
                    countdownString,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              unlocked ? l10n.recordSmoking : l10n.notUnlocked,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: unlocked ? _ThemeColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(14, 16, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaySmokingSchedule,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          Text(
            '${l10n.smokedCount}: ${engine.totalSmoked}/${engine.todayPlannedCount}',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: engine.schedule.length,
              itemBuilder: (context, index) {
                final time = engine.schedule[index];
                final now = DateTime.now();
                final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                final smoked = index < engine.totalSmoked;
                final past = now.isAfter(scheduled);
                final timeText = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                return SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Icon(
                        smoked
                            ? Icons.check_circle
                            : past
                                ? Icons.cancel_outlined
                                : Icons.lock_clock,
                        size: 16,
                        color: smoked
                            ? Colors.green
                            : past
                                ? Colors.grey
                                : _ThemeColors.accent,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        timeText,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        smoked
                            ? l10n.smoked
                            : past
                                ? l10n.notRecorded
                                : l10n.notUnlocked,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showSchedule,
                child: Text(l10n.todaySmokingSchedule),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: _ThemeColors.primary),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _buildBottomAction(Icons.sos, l10n.sos, _showSOS),
          _buildBottomAction(Icons.forum_outlined, l10n.forum, () => _openPage(const ForumPage())),
          _buildBottomAction(Icons.menu_book_outlined, l10n.readingArticleOfflineLabel, () => _openPage(const ReadingLibraryPage())),
          _buildBottomAction(Icons.video_library_outlined, l10n.youtubeVideoLabel, () => _openPage(const YouTubeLibraryPage())),
          _buildBottomAction(Icons.sports_esports_outlined, l10n.gameHub, () => _openPage(const GameHubPage())),
          _buildBottomAction(Icons.settings_outlined, l10n.settings, () => _openPage(const SetupPage())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_ThemeColors.bgTop, _ThemeColors.bgBottom],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.appTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white.withAlpha(220),
          elevation: 0,
          actions: [
            IconButton(
              tooltip: l10n.coinBalanceTitle,
              icon: const Icon(Icons.monetization_on, color: Colors.amber, size: 27),
              onPressed: () => _openPage(const CoinPage()),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                tooltip: l10n.settings,
                icon: const Icon(Icons.account_circle_outlined, color: _ThemeColors.primary, size: 28),
                onPressed: () => _openPage(const SetupPage()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: !_isLoaded
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        children: [
                          _buildConversationCard(),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildUnlockCard()),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTodayCard()),
                            ],
                          ),
                        ],
                      ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}
