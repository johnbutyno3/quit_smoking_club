import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final Future<SharedPreferences> _prefsInstance =
      SharedPreferences.getInstance();

  static Future<SharedPreferences> get _prefs async => _prefsInstance;

  static const _smokeRecordsKey = 'smoke_records';
  static const _smokeRecordsDateKey = 'smoke_records_date';

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
}
