import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveDailyCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_count', count);
    await prefs.reload();
    // 🔍 印出除錯訊息
    print("=== [儲存核心] 成功寫入抽菸數: $count ===");
  }

  static Future<int> getDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final count = prefs.getInt('daily_count') ?? 5;
    print("=== [讀取核心] 成功撈出抽菸數: $count ===");
    return count;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.reload();
    print("=== [儲存核心] 成功寫入姓名: $name ===");
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final name = prefs.getString('user_name') ?? "User";
    print("=== [讀取核心] 成功撈出姓名: $name ===");
    return name;
  }

  // 💾 儲存年齡
  static Future<void> saveUserAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', age);
    await prefs.reload();
  }

  // 📡 讀取年齡 (沒存過預設28)
  static Future<int> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt('user_age') ?? 28;
  }

  // 💾 儲存菸齡
  static Future<void> saveUserYears(int years) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_years', years);
    await prefs.reload();
  }

  // 📡 讀取菸齡 (沒存過預設8)
  static Future<int> getUserYears() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt('user_years') ?? 8;
  }

  // 💾 儲存最新金幣總數
  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_coins', coins);
    await prefs.reload();
  }

  // 📡 讀取目前金幣總數 (預設送50個)
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt('user_coins') ?? 50;
  }

  // 💾 儲存會員身份 (true 代表高級會員, false 代表一般)
  static Future<void> savePremium(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
    await prefs.reload();
  }

  // 📡 讀取會員身份 (預設先設為 false 模擬一般會員)
  static Future<bool> getPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool('is_premium') ?? false;
  }

  // 💾 儲存上次發放金幣的日期字串 (格式如: 2026-06-29)
  static Future<void> saveLastResetDate(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_reset_date', dateStr);
    await prefs.reload();
  }

  // 📡 讀取上次發放金幣的日期字串
  static Future<String> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString('last_reset_date') ?? "";
  }
}
