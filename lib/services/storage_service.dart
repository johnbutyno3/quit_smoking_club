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
}
