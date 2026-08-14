import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/smoking_plan.dart';
import '../models/smoking_state.dart';
import '../models/user_role.dart';
import '../models/user_smoking_status.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/achievement_engine.dart';
import '../services/coin_service.dart';
import '../services/recovery_engine.dart';
import '../services/smoking_engine.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../pages/coin_page.dart';
import '../l10n/app_localizations.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'mitigation_page.dart';
import 'reading_library_page.dart';
import 'music_library_page.dart';
import 'youtube_library_page.dart';
import 'schedule_page.dart';
import 'setup_page.dart';

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
  final CoinRepository _coinRepository = CoinRepository(
    coinService: CoinService(),
  );

  late SmokingEngine engine;
  late AchievementEngine achievement;
  late RecoveryEngine recovery;
  late SmokingState state;

  Timer? _timer;
  bool _isLoaded = false;
  int _myCoins = 0;
  bool _isVibrating = false;
  String? _activeNotification;
  bool _hasTriggeredUnlockNotify = false;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
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
      coinRepository: _coinRepository,
    );

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
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _loadStoredData();
    }
  }

  Future<void> _loadStoredData() async {
    final now = DateTime.now();
    final dailyCount = await StorageService.getDailyCount();
    final planStartDateStr = await StorageService.getPlanStartDate();
    final records = await StorageService.getSmokeRecordsForToday();
    final first = await StorageService.getFirstSmokeTime();
    final last = await StorageService.getLastSmokeTime();

    final firstParts = first.split(':');
    final lastParts = last.split(':');
    final firstHour = int.tryParse(firstParts.first) ?? 8;
    final firstMinute = firstParts.length > 1
        ? int.tryParse(firstParts[1]) ?? 0
        : 0;
    final lastHour = int.tryParse(lastParts.first) ?? 22;
    final lastMinute = lastParts.length > 1
        ? int.tryParse(lastParts[1]) ?? 0
        : 0;

    final planStartDate = planStartDateStr.isEmpty
        ? now
        : DateTime.tryParse(planStartDateStr) ?? now;

    var coins = await _coinRepository.getBalance();
    final isPremium = await StorageService.getPremium();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final lastReset = await StorageService.getLastResetDate();
    if (lastReset != todayKey) {
      final reward = isPremium ? 100 : 20;
      await StorageService.saveLastResetDate(todayKey);
      final uid = UserService.currentUid;
      if (uid != null) {
        try {
          await _coinRepository.addCoin(reward, 'daily_login_reward');
          coins = await _coinRepository.getBalance();
        } catch (_) {}
      }
    }

    if (!mounted) return;

    final loadedState = SmokingState(
      planStartDate: planStartDate,
      startTime: DateTime(now.year, now.month, now.day, firstHour, firstMinute),
      endTime: DateTime(now.year, now.month, now.day, lastHour, lastMinute),
      plannedCount: dailyCount,
      smokeRecords: records,
      lastSmokeTime: records.isEmpty ? null : records.last,
      role: UserRole.quitter,
      smokingStatus: SmokingStatus.smoker,
    );

    final loadedPlan = SmokingPlan(
      startTime: loadedState.startTime,
      endTime: loadedState.endTime,
      plannedCount: dailyCount,
    );

    final l10n = AppLocalizations.of(context);
    setState(() {
      state = loadedState;
      engine = SmokingEngine(loadedState, loadedPlan);
      recovery = RecoveryEngine(loadedState);
      achievement = AchievementEngine(
        smoking: engine,
        recovery: recovery,
        coinRepository: _coinRepository,
      );
      _myCoins = coins;
      _isLoaded = true;
      _messages
        ..clear()
        ..add(l10n?.welcomeMessage ?? '')
        ..add(l10n == null ? '' : '${l10n.hello}, ${UserService.currentDisplayName ?? ''}!');
      _messages.removeWhere((message) => message.trim().isEmpty);
    });

    await achievement.loadLoginStreak();
  }

  Future<void> _smoke() async {
    if (!canSmoke) return;
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      engine.state = engine.state.addSmoke(now);
      _messages.insert(0, l10n.smokeSuccessMessage);
    });

    await StorageService.saveSmokeRecords(engine.state.smokeRecords);
    _triggerVibration();
  }

  void _checkCountdownUnlock() {
    final unlockTime = engine.nextUnlockTime;
    if (unlockTime == null) return;
    final ready = !unlockTime.isAfter(DateTime.now());
    if (ready && !_hasTriggeredUnlockNotify) {
      _hasTriggeredUnlockNotify = true;
      final l10n = AppLocalizations.of(context)!;
      _showTopBanner(l10n.smokingUnlockNotification);
    } else if (!ready) {
      _hasTriggeredUnlockNotify = false;
    }
  }

  void _triggerVibration() {
    setState(() => _isVibrating = true);
    Future.delayed(const Duration(milliseconds: 250), () {
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

  void _openMessageHistory() {
    if (_messages.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        content: SizedBox(
          width: double.maxFinite,
          height: 360,
          child: ListView.separated(
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (_, index) => Text(
              _messages[index],
              style: const TextStyle(fontSize: 17, height: 1.45),
            ),
          ),
        ),
      ),
    );
  }

  void _triggerSOS() {
    final l10n = AppLocalizations.of(context)!;
    final quotes = <String>[
      l10n.motivationalQuote1,
      l10n.motivationalQuote2,
      l10n.motivationalQuote3,
      l10n.motivationalQuote4,
      l10n.motivationalQuote5,
    ];
    final quote = quotes[Random().nextInt(quotes.length)];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .52,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Text(
              l10n.cravingReliefChamberTitle,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              quote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, height: 1.4),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: Text(
                l10n.mitigationTileMedical,
                style: const TextStyle(fontSize: 17),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MitigationPage(title: l10n.sos),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoAudio() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(l10n.youtubeVideoLabel),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const YouTubeLibraryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(l10n.musicLinkLabel),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MusicLibraryPage(),
                  ),
                );
              },
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
      duration: const Duration(milliseconds: 60),
      padding: EdgeInsets.only(
        left: _isVibrating ? 5 : 0,
        right: _isVibrating ? 0 : 5,
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
            backgroundColor: Colors.white.withAlpha(220),
            elevation: 0,
            actions: [
              IconButton(
                tooltip: l10n.coinBalanceTitle,
                icon: const Icon(Icons.monetization_on, color: Colors.amber),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoinPage()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Center(
                  child: Text(
                    '$_myCoins',
                    style: const TextStyle(
                      color: _ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
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
              ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                children: [
                  _buildMainDashboard(),
                  const SizedBox(height: 12),
                  _buildMessageCard(),
                  const SizedBox(height: 12),
                  _buildBottomOptions(),
                ],
              ),
              if (_activeNotification != null)
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(14),
                    color: _ThemeColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _activeNotification!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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

  Widget _buildMainDashboard() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildTimerCard()),
        const SizedBox(width: 10),
        Expanded(child: _buildCombinedProgressCard()),
      ],
    );
  }

  Widget _buildTimerCard() {
    final l10n = AppLocalizations.of(context)!;
    final unlockTime = engine.nextUnlockTime;
    final isReady = unlockTime == null || !unlockTime.isAfter(DateTime.now());
    final diff = unlockTime == null
        ? Duration.zero
        : unlockTime.difference(DateTime.now());
    final remainingSeconds = max(0, diff.inSeconds);
    final totalSeconds = max(1, engine.intervalMinutes * 60);
    final progress = isReady
        ? 1.0
        : (1 - remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: isReady && canSmoke ? _smoke : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isReady ? l10n.smokingUnlockNotification : l10n.nextSmokeCountdown,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isReady ? 14 : 15,
                  fontWeight: FontWeight.bold,
                  color: isReady ? _ThemeColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 11,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        isReady ? Colors.orange : _ThemeColors.accent,
                      ),
                    ),
                    Text(
                      countdownString,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _ThemeColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isReady ? l10n.recordSmoking : l10n.notUnlocked,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedProgressCard() {
    final day = DateTime.now().difference(engine.state.planStartDate).inDays + 1;
    final total = engine.plan.durationDays;
    final achievementProgress = achievement.totalCount == 0
        ? 0.0
        : achievement.progress;
    final scheduleProgress = engine.todayPlannedCount == 0
        ? 0.0
        : (engine.totalSmoked / engine.todayPlannedCount).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      color: Colors.white.withAlpha(235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _miniProgress(
              icon: Icons.flag_circle_outlined,
              title: 'Day $day / $total',
              detail: '${engine.totalSmoked} / ${engine.todayPlannedCount}',
              progress: total == 0 ? 0 : (day / total).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 14),
            _miniProgress(
              icon: Icons.emoji_events_outlined,
              title: '${achievement.completedCount} / ${achievement.totalCount}',
              detail: l10n.achievementTitle,
              progress: achievementProgress,
            ),
            const SizedBox(height: 14),
            _miniProgress(
              icon: Icons.schedule_outlined,
              title: '${engine.totalSmoked} / ${engine.todayPlannedCount}',
              detail: l10n.todaySmokingSchedule,
              progress: scheduleProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniProgress({
    required IconData icon,
    required String title,
    required String detail,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: _ThemeColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _ThemeColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation(_ThemeColors.accent),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    if (_messages.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 1,
      color: Colors.white.withAlpha(235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _openMessageHistory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
          child: Row(
            children: [
              const Icon(Icons.forum_outlined, color: _ThemeColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _messages.first,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.35),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    final l10n = AppLocalizations.of(context)!;
    final items = <_HomeOption>[
      _HomeOption(l10n.sos, Icons.sos, Colors.redAccent, _triggerSOS),
      _HomeOption(
        l10n.forum,
        Icons.forum_outlined,
        Colors.blue,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForumPage()),
        ),
      ),
      _HomeOption(
        l10n.readingArticleOfflineLabel,
        Icons.menu_book_outlined,
        _ThemeColors.primary,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReadingLibraryPage()),
        ),
      ),
      _HomeOption(
        l10n.youtubeVideoLabel,
        Icons.video_library_outlined,
        Colors.deepPurple,
        _openVideoAudio,
      ),
      _HomeOption(
        l10n.gameHub,
        Icons.sports_esports_outlined,
        Colors.orange,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameHubPage()),
        ),
      ),
      _HomeOption(
        l10n.todaySmokingSchedule,
        Icons.calendar_today_outlined,
        Colors.teal,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SchedulePage()),
        ),
      ),
    ];

    return Card(
      elevation: 1,
      color: Colors.white.withAlpha(240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: items
              .map((item) => Expanded(child: _buildOption(item)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildOption(_HomeOption item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 22),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  bool get canSmoke {
    if (engine.totalSmoked >= engine.state.plannedCount) return false;
    return engine.availableSlots > engine.totalSmoked;
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

class _HomeOption {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeOption(this.label, this.icon, this.color, this.onTap);
}
