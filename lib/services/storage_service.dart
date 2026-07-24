import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/smoking_plan.dart';
import '../models/coin_transaction.dart';

class StorageService {
  static final Future<SharedPreferences> _prefsInstance =
      SharedPreferences.getInstance();

  static Future<SharedPreferences> get _prefs async => _prefsInstance;

  static const _smokeRecordsKey = 'smoke_records';
  static const _smokeRecordsDateKey = 'smoke_records_date';
  static const _coinHistoryKey = 'coin_history';
  static const _achievementClaimedKey = 'achievement_claimed';
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> saveDailyCount(int count) async {
    final prefs = await _prefs;
    await prefs.setInt('daily_count', count);
  }

  static Future<int> getDailyCount() async {
    final prefs = await _prefs;
    return prefs.getInt('daily_count') ?? 5;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString('user_name', name);
  }

  static Future<String> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString('user_name') ?? '';
  }

  // 💾 儲存年齡
  static Future<void> saveUserAge(int age) async {
    final prefs = await _prefs;
    await prefs.setInt('user_age', age);
  }

  // 📡 讀取年齡 (沒存過預設28)
  static Future<int> getUserAge() async {
    final prefs = await _prefs;
    return prefs.getInt('user_age') ?? 28;
  }

  // 💾 儲存菸齡
  static Future<void> saveUserYears(int years) async {
    final prefs = await _prefs;
    await prefs.setInt('user_years', years);
  }

  // 📡 讀取菸齡 (沒存過預設8)
  static Future<int> getUserYears() async {
    final prefs = await _prefs;
    return prefs.getInt('user_years') ?? 8;
  }

  // 💾 儲存每包香菸價格
  static Future<void> saveCigarettePrice(int price) async {
    final prefs = await _prefs;
    await prefs.setInt('cigarette_price', price);
  }

  // 📡 讀取每包香菸價格
  static Future<int> getCigarettePrice() async {
    final prefs = await _prefs;
    return prefs.getInt('cigarette_price') ?? 120;
  }

  static Future<void> saveSmokeRecords(List<DateTime> records) async {
    final prefs = await _prefs;
    final todayKey = _formatDateKey(DateTime.now());
    final recordStrings = records.map((r) => r.toIso8601String()).toList();
    await prefs.setStringList(_smokeRecordsKey, recordStrings);
    await prefs.setString(_smokeRecordsDateKey, todayKey);
  }

  static Future<List<DateTime>> getSmokeRecordsForToday() async {
    final prefs = await _prefs;
    final storedDate = prefs.getString(_smokeRecordsDateKey);
    final todayKey = _formatDateKey(DateTime.now());
    if (storedDate != todayKey) {
      return [];
    }
    final list = prefs.getStringList(_smokeRecordsKey) ?? [];
    final records = list
        .map((item) => DateTime.tryParse(item))
        .whereType<DateTime>()
        .toList();
    records.sort();
    return records;
  }

  // 💾 儲存最新金幣總數
  static Future<void> saveCoins(int coins) async {
    final prefs = await _prefs;
    await prefs.setInt('user_coins', coins);
  }

  // 📡 讀取目前金幣總數 (預設送50個)
  static Future<int> getCoins() async {
    final prefs = await _prefs;
    return prefs.getInt('user_coins') ?? 50;
  }

  // ⭐ COIN交易紀錄讀取
  static Future<List<CoinTransaction>> getCoinHistory() async {
    final prefs = await _prefs;

    final data = prefs.getStringList(_coinHistoryKey);

    if (data == null) {
      return [];
    }

    return data.map((e) {
      return CoinTransaction.fromJson(jsonDecode(e));
    }).toList();
  }

  // ⭐ COIN交易紀錄保存
  static Future<void> saveCoinHistory(List<CoinTransaction> history) async {
    final prefs = await _prefs;

    final data = history.map((e) {
      return jsonEncode(e.toJson());
    }).toList();

    await prefs.setStringList(_coinHistoryKey, data);
  }

  // 💾 儲存會員身份 (true 代表高級會員, false 代表一般)
  static Future<void> savePremium(bool isPremium) async {
    final prefs = await _prefs;
    await prefs.setBool('is_premium', isPremium);
  }

  // 📡 讀取會員身份 (預設先設為 false 模擬一般會員)
  static Future<bool> getPremium() async {
    final prefs = await _prefs;
    return prefs.getBool('is_premium') ?? false;
  }

  // 💾 儲存上次發放金幣的日期字串 (格式如: 2026-06-29)
  static Future<void> saveLastResetDate(String dateStr) async {
    final prefs = await _prefs;
    await prefs.setString('last_reset_date', dateStr);
  }

  // 📡 讀取上次發放金幣的日期字串
  static Future<String> getLastResetDate() async {
    final prefs = await _prefs;
    return prefs.getString('last_reset_date') ?? "";
  }

  // 💾 儲存第一支菸時間，格式 "HH:MM"，預設 "08:00"
  static Future<void> saveFirstSmokeTime(String hhmm) async {
    final prefs = await _prefs;
    await prefs.setString('first_smoke_time', hhmm);
  }

  static Future<String> getFirstSmokeTime() async {
    final prefs = await _prefs;
    return prefs.getString('first_smoke_time') ?? '08:00';
  }

  // 💾 儲存最後一支菸時間，格式 "HH:MM"，預設 "22:00"
  static Future<void> saveLastSmokeTime(String hhmm) async {
    final prefs = await _prefs;
    await prefs.setString('last_smoke_time', hhmm);
  }

  static Future<String> getLastSmokeTime() async {
    final prefs = await _prefs;
    return prefs.getString('last_smoke_time') ?? '22:00';
  }

  // 💾 儲存戈菸計畫開始日期（格式 "YYYY-MM-DD"）
  static Future<void> savePlanStartDate(String date) async {
    final prefs = await _prefs;
    await prefs.setString('plan_start_date', date);
  }

  static Future<String> getPlanStartDate() async {
    final prefs = await _prefs;
    return prefs.getString('plan_start_date') ?? '';
  }

  // 💾 儲存戈菸計畫總天數（預設 90）
  static Future<void> savePlanDurationDays(int days) async {
    final prefs = await _prefs;
    await prefs.setInt('plan_duration_days', days);
  }

  static Future<int> getPlanDurationDays() async {
    final prefs = await _prefs;
    return prefs.getInt('plan_duration_days') ?? 90;
  }

  // 💾 儲存指定日期的抽菸實際支數
  static Future<void> saveDayActual(String dateKey, int count) async {
    final prefs = await _prefs;
    await prefs.setInt('actual_$dateKey', count);
  }

  static Future<int> getDayActual(String dateKey) async {
    final prefs = await _prefs;
    return prefs.getInt('actual_$dateKey') ?? -1; // -1 表示無記錄
  }

  // 💾 是否已顯示過 Intro 滑動介紹
  static Future<void> saveIntroShown(bool shown) async {
    final prefs = await _prefs;
    await prefs.setBool('intro_shown', shown);
  }

  static Future<bool> getIntroShown() async {
    final prefs = await _prefs;
    return prefs.getBool('intro_shown') ?? false;
  }

  static Future<void> saveSmokingPlan(SmokingPlan plan) async {
    await saveDailyCount(plan.plannedCount);
    await savePlanDurationDays(plan.durationDays);

    final start =
        "${plan.startTime.hour.toString().padLeft(2, '0')}:${plan.startTime.minute.toString().padLeft(2, '0')}";

    final end =
        "${plan.endTime.hour.toString().padLeft(2, '0')}:${plan.endTime.minute.toString().padLeft(2, '0')}";

    await saveFirstSmokeTime(start);
    await saveLastSmokeTime(end);
  }

  static Future<SmokingPlan> loadSmokingPlan() async {
    final daily = await getDailyCount();
    final days = await getPlanDurationDays();

    final first = await getFirstSmokeTime();
    final last = await getLastSmokeTime();

    final now = DateTime.now();

    final firstParts = first.split(':');
    final lastParts = last.split(':');

    return SmokingPlan(
      startTime: DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(firstParts[0]),
        int.parse(firstParts[1]),
      ),
      endTime: DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(lastParts[0]),
        int.parse(lastParts[1]),
      ),
      plannedCount: daily,
      durationDays: days,
    );
  }

  static Future<List<String>> getClaimedAchievements() async {
    final prefs = await _prefs;

    return prefs.getStringList(_achievementClaimedKey) ?? [];
  }

  static Future<void> saveClaimedAchievement(String achievementId) async {
    final prefs = await _prefs;

    final list = prefs.getStringList(_achievementClaimedKey) ?? [];

    if (!list.contains(achievementId)) {
      list.add(achievementId);

      await prefs.setStringList(_achievementClaimedKey, list);
    }
  }
}
